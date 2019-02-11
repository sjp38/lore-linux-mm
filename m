Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_NEOMUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 31062C169C4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 19:06:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DEE4321B68
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 19:06:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="OH6iGjT0"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DEE4321B68
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 62AE38E0133; Mon, 11 Feb 2019 14:06:37 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 600568E012D; Mon, 11 Feb 2019 14:06:37 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4C96A8E0133; Mon, 11 Feb 2019 14:06:37 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1FDE48E012D
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 14:06:37 -0500 (EST)
Received: by mail-yw1-f70.google.com with SMTP id z123so6043ywf.4
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 11:06:37 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=1byxMH4cS5DA8jf3Vc8nsnHQYzCL4Eu4MKOQbBwKaQA=;
        b=htbpctFaARynK4utRmsqdfRjHAQhVDPjrPbVX1TPYkMfs8DIbuaC4J0yuTJL8FdBxe
         cW4N1KyVM0lmzw5rDVE6GFe7SaAXy2b6CLnDSeX7go5hN2h5Zt/7S6iaEoeMN/IbWymG
         QdL1lvFG651QgK6xQVhSaqChoEkPDbtGD1HsXa9HkeK16XA47yD1yfFuczVfPI5T19nn
         svJtEW6+hKn4XATb7fAXR7T/teQNZP4LXaMUMPuJ6kZqCvM8EbtAa9U7qPKBYScd99hs
         ueOVBPT20Zc+gHE+2cd3IryCwkQfGhvcFmTqiDnJuwVAVQlmb3HgNhVdD2F9e8cTva3H
         4XKQ==
X-Gm-Message-State: AHQUAuYrx+1z2mPLOcCWvZNknV2V5ole+wXcOgsHU5G9srYbTp5b/pQc
	FkUPaxl2/l2zILzcWmueDgEx7KjUwwax55MR1qXKS/rpxj5JReNj9YmFHikEecNZEvv+Tim07QY
	mTVkpyDGcsyv6CeYOdHdrWNlc9sRXln68QERvrhFekLFfqHJHdNdIx36XFX+t5fAwvg==
X-Received: by 2002:a81:b189:: with SMTP id p131mr28243133ywh.92.1549911996814;
        Mon, 11 Feb 2019 11:06:36 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaKm0joPYdpTB3m9W049WBSxlvzYhxl5R73mhu+OExZkcmdpayLw/X7rnPoo/R1wjFhUnrB
X-Received: by 2002:a81:b189:: with SMTP id p131mr28243094ywh.92.1549911996295;
        Mon, 11 Feb 2019 11:06:36 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549911996; cv=none;
        d=google.com; s=arc-20160816;
        b=ns7fhegFXGbYJam1j3Kpn6aBi0w2UQGJklEVBTDrE+TKHq8GWLgfGH4hU+5+gL1eit
         7+8922wgq2mfut+km7SNdTKfZ7U/DtJE76Q8A/0OMSlFtTz/QWKiHemt8iCkUuYjtoBR
         gOVuVuzSjVyNts0nquh6LiuN2VDr92+Vvksl7MdvaAqEd/Tk3tzRxuIOU5Sfz6Zs4oEG
         iuu9Y0Nb8yjwzGI0QVO7MW7p/T3uOD9yv4LE90OJp4+FuFS7chM2CzNYeSxoaiTbncHP
         ejTJtkpEeu/oC68m8gQwTfqFhx1OCVgWVS9YKWZ73wV50U28p+wTugYZO4zTd7o6Tx5t
         wrqg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=1byxMH4cS5DA8jf3Vc8nsnHQYzCL4Eu4MKOQbBwKaQA=;
        b=os7AvuKyspfF4N7UWmoPsh+P7i3ECTgTYZBYmDPI34n1FCrUM/yp/u3CoqLyuV11NI
         4Vcd7DExSpg0xy8kyFJuoTUzCAlgxqG1ZvLaV3ZgOX71D37HGe0syqKpZcpzyrCjmYYg
         SvByhxJJi5uXjCqPZsK2rlooxqRteIODqwXod77bWjVdH7Dzc4LU7H2aj6YmH3m3ihq0
         z1xYjOeAGxttGD8VGd9kkZpxbnQ6ZM0O8uhpXw6kEWQbiZihSJNDfBbvvWZV4I898b/p
         MomEV4tdHfSsmGmFgfSXJNHUY/U4CLezVeqHx73pswCE3MkAl0v3XJzaZYZS2CMnXyI+
         i3iA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=OH6iGjT0;
       spf=pass (google.com: domain of daniel.m.jordan@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=daniel.m.jordan@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id a140si6439391ywh.166.2019.02.11.11.06.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 11:06:36 -0800 (PST)
Received-SPF: pass (google.com: domain of daniel.m.jordan@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=OH6iGjT0;
       spf=pass (google.com: domain of daniel.m.jordan@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=daniel.m.jordan@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x1BJ4E2e093492;
	Mon, 11 Feb 2019 19:06:29 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=date : from : to : cc
 : subject : message-id : references : mime-version : content-type :
 in-reply-to; s=corp-2018-07-02;
 bh=1byxMH4cS5DA8jf3Vc8nsnHQYzCL4Eu4MKOQbBwKaQA=;
 b=OH6iGjT02b6/sqHMTKcJDBzQT4lRUfMvpdAE4yTmcBYmg6JDX6kzAyCh6yi/bhMvTvz+
 EZkNZW5nHkfFFrK0i9jWl06MAr/dTk8xbndOKqJBxETuBv2piWoc8SAwh+K8su1I3JfG
 h1KvmwVgAQMwEHdI1mwehooCsqH8CPZfbx7Y1O87wJpV42KSbutbbc8E1kp27qoRSiwu
 N5o6Pf0cxHeEzr5YQT3DCA67eG99QUBlFNYaKKI3kvTEmHdUJn5XLnLWSzpwQdPFRcR9
 Zh2IziawY916WZ5eebEABc+7Gt4lhELKgmZDTUl0mUlVdWUIviQKAObD8LIYGVC9lNKs Dw== 
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
	by userp2120.oracle.com with ESMTP id 2qhredqpq3-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 11 Feb 2019 19:06:29 +0000
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x1BJ6SeF031440
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 11 Feb 2019 19:06:28 GMT
Received: from abhmp0008.oracle.com (abhmp0008.oracle.com [141.146.116.14])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x1BJ6QlV020484;
	Mon, 11 Feb 2019 19:06:26 GMT
Received: from ca-dmjordan1.us.oracle.com (/10.211.9.48)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Mon, 11 Feb 2019 11:06:26 -0800
Date: Mon, 11 Feb 2019 14:06:46 -0500
From: Daniel Jordan <daniel.m.jordan@oracle.com>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>,
        "Paul E . McKenney" <paulmck@linux.vnet.ibm.com>,
        Minchan Kim <minchan@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>,
        Tim Chen <tim.c.chen@linux.intel.com>,
        Mel Gorman <mgorman@techsingularity.net>,
        =?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>,
        Michal Hocko <mhocko@suse.com>, Andrea Arcangeli <aarcange@redhat.com>,
        David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>,
        Jan Kara <jack@suse.cz>, Dave Jiang <dave.jiang@intel.com>,
        Daniel Jordan <daniel.m.jordan@oracle.com>,
        Andrea Parri <andrea.parri@amarulasolutions.com>
Subject: Re: [PATCH -mm -V7] mm, swap: fix race between swapoff and some swap
 operations
Message-ID: <20190211190646.j6pdxqirc56inbbe@ca-dmjordan1.us.oracle.com>
References: <20190211083846.18888-1-ying.huang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190211083846.18888-1-ying.huang@intel.com>
User-Agent: NeoMutt/20180323-268-5a959c
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9164 signatures=668683
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=764 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1902110139
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 11, 2019 at 04:38:46PM +0800, Huang, Ying wrote:
> +struct swap_info_struct *get_swap_device(swp_entry_t entry)
> +{
> +	struct swap_info_struct *si;
> +	unsigned long type, offset;
> +
> +	if (!entry.val)
> +		goto out;

> +	type = swp_type(entry);
> +	si = swap_type_to_swap_info(type);

These lines can be collapsed into swp_swap_info if you want.

> +	if (!si)
> +		goto bad_nofile;
> +
> +	preempt_disable();
> +	if (!(si->flags & SWP_VALID))
> +		goto unlock_out;

After Hugh alluded to barriers, it seems the read of SWP_VALID could be
reordered with the write in preempt_disable at runtime.  Without smp_mb()
between the two, couldn't this happen, however unlikely a race it is?

CPU0                                CPU1

__swap_duplicate()
    get_swap_device()
        // sees SWP_VALID set
                                   swapoff
                                       p->flags &= ~SWP_VALID;
                                       spin_unlock(&p->lock); // pair w/ smp_mb
                                       ...
                                       stop_machine(...)
                                       p->swap_map = NULL;
        preempt_disable()
    read NULL p->swap_map

