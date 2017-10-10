Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id A34216B0260
	for <linux-mm@kvack.org>; Tue, 10 Oct 2017 17:34:09 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id i124so467832wmf.7
        for <linux-mm@kvack.org>; Tue, 10 Oct 2017 14:34:09 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id s3si9829543wmb.174.2017.10.10.14.34.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Oct 2017 14:34:08 -0700 (PDT)
Date: Tue, 10 Oct 2017 14:34:05 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v3] mm, sysctl: make NUMA stats configurable
Message-Id: <20171010143405.fd03274b12bbda0eba00362e@linux-foundation.org>
In-Reply-To: <20171010175143.q4bz43dtn4eyn32j@dhcp22.suse.cz>
References: <1506579101-5457-1-git-send-email-kemi.wang@intel.com>
	<20171003092352.2wh2jbtt2dudfi5a@dhcp22.suse.cz>
	<221a1e93-ee33-d598-67de-d6071f192040@intel.com>
	<20171009075549.pzohdnerillwuhqo@dhcp22.suse.cz>
	<20171010054902.sqp6yyid6qqhpsrt@dhcp22.suse.cz>
	<bb13e610-758e-0fdd-ee65-781b4920f1c6@linux.intel.com>
	<20171010143113.gk6iqcrguefhhlmr@dhcp22.suse.cz>
	<eb9248f9-1941-57f9-de9e-596b4ead6491@linux.intel.com>
	<20171010145728.q2levvekbpwlg57q@dhcp22.suse.cz>
	<4949ccef-6b7f-c2d6-f500-92eadb2ba649@linux.intel.com>
	<20171010175143.q4bz43dtn4eyn32j@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, kemi <kemi.wang@intel.com>, "Luis R . Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, Jonathan Corbet <corbet@lwn.net>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Christopher Lameter <cl@linux.com>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Vlastimil Babka <vbabka@suse.cz>, Tim Chen <tim.c.chen@intel.com>, Andi Kleen <andi.kleen@intel.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Ying Huang <ying.huang@intel.com>, Aaron Lu <aaron.lu@intel.com>, Proc sysctl <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>

On Tue, 10 Oct 2017 19:51:43 +0200 Michal Hocko <mhocko@kernel.org> wrote:

> On Tue 10-10-17 08:39:47, Dave Hansen wrote:
> > On 10/10/2017 07:57 AM, Michal Hocko wrote:
> > >> But, let's be honest, this leaves us with an option that nobody is ever
> > >> going to turn on.  IOW, nobody except a very small portion of our users
> > >> will ever see any benefit from this.
> > > But aren't those small groups who would like to squeeze every single
> > > cycle out from the page allocator path the targeted audience?
> > 
> > They're the reason we started looking at this.  They also care the most.
> > 
> > But, the cost of these stats, especially we get more and more cores in a
> > NUMA node is really making them show up in profiles.  It would be nice
> > to get rid of them there, too.
> 
> I am not opposing to the auto mode. I am just not sure it is a safe
> default and I also think that we should add this on top if it is really
> needed.

Yup.  Let's keep things simple unless a real need is demonstrated, please.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
