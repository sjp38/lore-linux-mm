Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AAED6C282C4
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 15:56:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 66CE520842
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 15:56:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 66CE520842
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CDF858E0002; Tue, 12 Feb 2019 10:56:18 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C65758E0001; Tue, 12 Feb 2019 10:56:18 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B07D98E0002; Tue, 12 Feb 2019 10:56:18 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 824698E0001
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 10:56:18 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id 207so8050409qkf.9
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 07:56:18 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:reply-to:references:mime-version:content-disposition
         :in-reply-to:user-agent:message-id;
        bh=wskkirGtVbS4ATv6Evn/45a6IDFb32ktNYk9xlWKcHg=;
        b=Hevqx4xJVNS9pYJ5lveqJrUysDImLhCH7P0tgDniYoe4leFKhmcwMtRfMTLEAGg5uK
         SpDcDoqAPVbEyRDchxNrc70BjPzbbR87VHEudALvu2d9QefBHPQLulAqLT6U1KFNGM9i
         siGPSr4jENu0jyXvZOPnyB8Gsbq6oHwnU8vlHUh6ULy3SNaBX4pH4g7GBQK+aLzhD4M5
         EUZAji3EzgnxZjxLAtLJpeCO6MXeCQ7zCerkgH3XCWySmk635nt2cZPZWbMeiVV9yOPs
         v6IQF6McV8Hx6uIOYTvKKsWcIEk8uwFmQj3P0kM6jc+z33qx0kcybWX0IsVKi+wGlRen
         TZMA==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 148.163.158.5 is neither permitted nor denied by best guess record for domain of paulmck@linux.vnet.ibm.com) smtp.mailfrom=paulmck@linux.vnet.ibm.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AHQUAuZNT40FOTDlxpFj5ipoYlBYzkm4NNoOOvDRRYiZuUreEAAOD2Xi
	xwfct1wqV+B6/ElOT5Zv0sV4T/jG/1t1NXIuRP9wNKzYRgGwVpBIti8JdTx5H2TGvo+jkgtmoSE
	tVn7qH3QjgqA+iUng16HuYUN8IO90o/x36eV8o5QginAIKGEV2/9TZKCqndh+ixc=
X-Received: by 2002:a37:a546:: with SMTP id o67mr3100361qke.42.1549986978291;
        Tue, 12 Feb 2019 07:56:18 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZis50mcdoOnRSMIV73m6/SGhDQ3FZBb4f93FYxj6y3HN5ZXwiC4xQvXGBVrn5ZbjA/2pHc
X-Received: by 2002:a37:a546:: with SMTP id o67mr3100322qke.42.1549986977614;
        Tue, 12 Feb 2019 07:56:17 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549986977; cv=none;
        d=google.com; s=arc-20160816;
        b=uyOLG6CQkmPNl64KjJXW7fvUAbD0sY4BodmNDyA//nf1oG0qfIelCIwsxQudIXXcK3
         U9HhsBOMb1k1Eu8ilqE857Dvgv96l//myoj6+AxZpPNKaM1/xfLhTlNyuGUjietW7uSQ
         clw+RhNqHeZEL14H2lzvhF+r/gUF5LQN1upoNMFOEQ5hDBGGTZGl47Zh5+zyl4njhX9B
         H/GD5EMbTVKtM9LkjV0DBfA+dTxZqLI1jbX+oPObzJ0Wi70jPol1721Svv6PzWZMSvs5
         uHY3cs4WIUirdx7aE3vY7z+vjy+mdzF0k9kLFpU0j0onupshjD0HrLlBicPUAS7/AbIj
         DlNg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:reply-to:subject:cc:to:from:date;
        bh=wskkirGtVbS4ATv6Evn/45a6IDFb32ktNYk9xlWKcHg=;
        b=YKkAog/FzDEidXg3Biwrb5OIqDhC7la3kLGaeGku0SbEg/ZK+9nyYjZD5cO3gt42AS
         C73l5QnpY3/cChxjVXQV5brGDe5mKmwepitsTolghe+o98WDtpPsgHSJH6OugaXohfDv
         TU5i7ut+ndduyG6MlHDi89OyPKhAsn3DY6fPuyPEQHHPONOPhQVxp/QWzZzpnpMMjlSv
         4t9RgtNrDwqlMGuBwyqvc6oeWa0JUaG9+MF7Qbli3DToM68iy34DydK+hIk4Gx1JTuJh
         aIenSv99Sgp4kVILS4pJqSu1f39fTn4neliDtVEOKFIQJhLGFlhK7WOa6adUaxP6tKjm
         5e7Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 148.163.158.5 is neither permitted nor denied by best guess record for domain of paulmck@linux.vnet.ibm.com) smtp.mailfrom=paulmck@linux.vnet.ibm.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id i66si4213658qkf.246.2019.02.12.07.56.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Feb 2019 07:56:17 -0800 (PST)
Received-SPF: neutral (google.com: 148.163.158.5 is neither permitted nor denied by best guess record for domain of paulmck@linux.vnet.ibm.com) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 148.163.158.5 is neither permitted nor denied by best guess record for domain of paulmck@linux.vnet.ibm.com) smtp.mailfrom=paulmck@linux.vnet.ibm.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x1CFtkkr101463
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 10:56:17 -0500
Received: from e15.ny.us.ibm.com (e15.ny.us.ibm.com [129.33.205.205])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2qm0xvgvn2-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 10:56:16 -0500
Received: from localhost
	by e15.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Tue, 12 Feb 2019 15:56:16 -0000
Received: from b01cxnp23034.gho.pok.ibm.com (9.57.198.29)
	by e15.ny.us.ibm.com (146.89.104.202) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 12 Feb 2019 15:56:11 -0000
Received: from b01ledav003.gho.pok.ibm.com (b01ledav003.gho.pok.ibm.com [9.57.199.108])
	by b01cxnp23034.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x1CFuAON21168176
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 12 Feb 2019 15:56:11 GMT
Received: from b01ledav003.gho.pok.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id DE72DB2064;
	Tue, 12 Feb 2019 15:56:10 +0000 (GMT)
Received: from b01ledav003.gho.pok.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id C161BB205F;
	Tue, 12 Feb 2019 15:56:10 +0000 (GMT)
Received: from paulmck-ThinkPad-W541 (unknown [9.70.82.41])
	by b01ledav003.gho.pok.ibm.com (Postfix) with ESMTP;
	Tue, 12 Feb 2019 15:56:10 +0000 (GMT)
Received: by paulmck-ThinkPad-W541 (Postfix, from userid 1000)
	id E773116C5EB2; Tue, 12 Feb 2019 07:56:10 -0800 (PST)
Date: Tue, 12 Feb 2019 07:56:10 -0800
From: "Paul E. McKenney" <paulmck@linux.ibm.com>
To: Matthew Wilcox <willy@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
        kbuild test robot <lkp@intel.com>,
        Suren Baghdasaryan <surenb@google.com>, kbuild-all@01.org,
        Johannes Weiner <hannes@cmpxchg.org>,
        Linux Memory Management List <linux-mm@kvack.org>
Subject: Re: [linux-next:master 6618/6917] kernel/sched/psi.c:1230:13:
 sparse: error: incompatible types in comparison expression (different
 address spaces)
Reply-To: paulmck@linux.ibm.com
References: <201902080231.RZbiWtQ6%fengguang.wu@intel.com>
 <20190208151441.4048e6968579dd178b259609@linux-foundation.org>
 <20190209074407.GE4240@linux.ibm.com>
 <20190212013606.GJ12668@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190212013606.GJ12668@bombadil.infradead.org>
User-Agent: Mutt/1.5.21 (2010-09-15)
X-TM-AS-GCONF: 00
x-cbid: 19021215-0068-0000-0000-00000392B119
X-IBM-SpamModules-Scores: 
X-IBM-SpamModules-Versions: BY=3.00010583; HX=3.00000242; KW=3.00000007;
 PH=3.00000004; SC=3.00000279; SDB=6.01160037; UDB=6.00605417; IPR=6.00940588;
 MB=3.00025547; MTD=3.00000008; XFM=3.00000015; UTC=2019-02-12 15:56:14
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19021215-0069-0000-0000-0000477BB64C
Message-Id: <20190212155610.GJ4240@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-02-12_09:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1902120113
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 11, 2019 at 05:36:06PM -0800, Matthew Wilcox wrote:
> On Fri, Feb 08, 2019 at 11:44:07PM -0800, Paul E. McKenney wrote:
> > On Fri, Feb 08, 2019 at 03:14:41PM -0800, Andrew Morton wrote:
> > > On Fri, 8 Feb 2019 02:29:33 +0800 kbuild test robot <lkp@intel.com> wrote:
> > > 
> > > > tree:   https://urldefense.proofpoint.com/v2/url?u=https-3A__git.kernel.org_pub_scm_linux_kernel_git_next_linux-2Dnext.git&d=DwICAg&c=jf_iaSHvJObTbx-siA1ZOg&r=q4hkQkeaNH3IlTsPvEwkaUALMqf7y6jCMwT5b6lVQbQ&m=myIJaLgovNwHx7SqCW_p1sQx2YvRlmVbShFnuZEFqxY&s=0Y32d-tVCGOq6Vu_VAGgVgbEplhfvOSJ5evHbXTtyBI&e= master
> > > > head:   1bd831d68d5521c01d783af0275439ac645f5027
> > > > commit: e7acbba0d6f7a24c8d24280089030eb9a0eb7522 [6618/6917] psi: introduce psi monitor
> > > > reproduce:
> > > >         # apt-get install sparse
> > > >         git checkout e7acbba0d6f7a24c8d24280089030eb9a0eb7522
> > > >         make ARCH=x86_64 allmodconfig
> > > >         make C=1 CF='-fdiagnostic-prefix -D__CHECK_ENDIAN__'
> > > > 
> > > > All errors (new ones prefixed by >>):
> > > > 
> > > >    kernel/sched/psi.c:151:6: sparse: warning: symbol 'psi_enable' was not declared. Should it be static?
> > > > >> kernel/sched/psi.c:1230:13: sparse: error: incompatible types in comparison expression (different address spaces)
> > > >    kernel/sched/psi.c:774:30: sparse: warning: dereference of noderef expression
> > > > 
> > > > vim +1230 kernel/sched/psi.c
> > > > 
> > > >   1222	
> > > >   1223	static __poll_t psi_fop_poll(struct file *file, poll_table *wait)
> > > >   1224	{
> > > >   1225		struct seq_file *seq = file->private_data;
> > > >   1226		struct psi_trigger *t;
> > > >   1227		__poll_t ret;
> > > >   1228	
> > > >   1229		rcu_read_lock();
> > > > > 1230		t = rcu_dereference(seq->private);
> 
> So the problem here is the opposite of what we think it is -- seq->private
> is not marked as being RCU protected.

Glad to have helped, then.  ;-)

> > If you wish to opt into this checking, you need to mark the pointer
> > definitions (in this case ->private) with __rcu.  It may also
> > be necessary to mark function parameters as well, as is done for
> > radix_tree_iter_resume().  If you do not wish to use this checking,
> > you should ignore these sparse warnings.
> 
> radix_tree_iter_resume is, happily, gone from my xarray-conv tree.
> __radix_tree_lookup, __radix_tree_replace, radix_tree_iter_replace and
> radix_tree_iter_init are still present, but hopefully not for too much
> longer.  For example, __radix_tree_replace() is (now) called only from
> idr_replace(), and there are only 12 remaining callers of idr_replace().

Will this reduce the number of uses of rcu_dereference_raw()?  Or do they
simply migrate into Xarray?

							Thanx, Paul

