Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0E6306B038A
	for <linux-mm@kvack.org>; Tue, 21 Mar 2017 11:18:19 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id t143so104650606pgb.1
        for <linux-mm@kvack.org>; Tue, 21 Mar 2017 08:18:19 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id h21si21553896pgj.54.2017.03.21.08.18.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Mar 2017 08:18:18 -0700 (PDT)
Message-ID: <1490109496.17719.15.camel@linux.intel.com>
Subject: Re: [PATCH v2 0/5] mm: support parallel free of memory
From: Tim Chen <tim.c.chen@linux.intel.com>
Date: Tue, 21 Mar 2017 11:18:16 -0400
In-Reply-To: <20170316090732.GF30501@dhcp22.suse.cz>
References: <1489568404-7817-1-git-send-email-aaron.lu@intel.com>
	 <20170315141813.GB32626@dhcp22.suse.cz>
	 <20170315154406.GF2442@aaronlu.sh.intel.com>
	 <20170315162843.GA27197@dhcp22.suse.cz>
	 <1489613914.2733.96.camel@linux.intel.com>
	 <20170316090732.GF30501@dhcp22.suse.cz>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Aaron Lu <aaron.lu@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dave Hansen <dave.hansen@intel.com>, Tim Chen <tim.c.chen@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Ying Huang <ying.huang@intel.com>

On Thu, 2017-03-16 at 10:07 +0100, Michal Hocko wrote:
>A 
> > > the main problem is that kworkers will not belong to the same cpu group
> > > and so they will not be throttled properly.
> > You do have a point that this page freeing activities should strive to
> > affect other threads not in the same cgroup minimally.
> > 
> > On the other hand, we also don't do this throttling of kworkersA 
> > today (e.g. pdflush) according to the cgroup it is doing work for.
> Yes, I am not saying this a new problem. I just wanted to point out that
> this is something to consider here. I believe this should be fixable.
> Worker can attach to the same cgroup the initiator had for example
> (assuming the cgroup core allows that which is something would have to
> be checked).

Instead of attaching the kworders to the cgroup of the initiator, I
wonder what people think about creating a separate kworker cgroup.A 
The administrator can set limit on its cpu resource bandwidth
if he/she does not want such kworkers perturbing the system.

Tim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
