Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3277A6B0253
	for <linux-mm@kvack.org>; Fri, 12 Aug 2016 12:26:51 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id ag5so463821pad.2
        for <linux-mm@kvack.org>; Fri, 12 Aug 2016 09:26:51 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id c9si653073pav.143.2016.08.12.09.26.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Aug 2016 09:26:50 -0700 (PDT)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u7CGNYEZ109109
	for <linux-mm@kvack.org>; Fri, 12 Aug 2016 12:26:48 -0400
Received: from e36.co.us.ibm.com (e36.co.us.ibm.com [32.97.110.154])
	by mx0a-001b2d01.pphosted.com with ESMTP id 24s2v8ekrc-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 12 Aug 2016 12:26:48 -0400
Received: from localhost
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Fri, 12 Aug 2016 10:26:47 -0600
Date: Fri, 12 Aug 2016 09:26:46 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 09/10] vhost, mm: make sure that oom_reaper doesn't	reap
 memory read by vhost
Reply-To: paulmck@linux.vnet.ibm.com
References: <20160728233359-mutt-send-email-mst@kernel.org>
 <20160729060422.GA5504@dhcp22.suse.cz>
 <20160729161039-mutt-send-email-mst@kernel.org>
 <20160729133529.GE8031@dhcp22.suse.cz>
 <20160729205620-mutt-send-email-mst@kernel.org>
 <20160731094438.GA24353@dhcp22.suse.cz>
 <20160812094236.GF3639@dhcp22.suse.cz>
 <20160812132140.GA776@redhat.com>
 <20160812155734.GT3482@linux.vnet.ibm.com>
 <20160812160930.GB30930@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160812160930.GB30930@redhat.com>
Message-Id: <20160812162646.GW3482@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Vladimir Davydov <vdavydov@parallels.com>, "Michael S. Tsirkin" <mst@redhat.com>

On Fri, Aug 12, 2016 at 06:09:30PM +0200, Oleg Nesterov wrote:
> On 08/12, Paul E. McKenney wrote:
> >
> > Hmmm...  What source tree are you guys looking at?  I am seeing some
> > of the above being macros rather than functions and others not being
> > present at all...
> 
> Sorry for confusion. These code snippets are form Michal's patches. I hope
> he will write another email to unconfuse you ;)

Actually, I suspect that you have it as well in hand as I would have.  ;-)

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
