Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 700B06B0260
	for <linux-mm@kvack.org>; Tue, 10 Oct 2017 01:55:52 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id v2so2016808pfa.4
        for <linux-mm@kvack.org>; Mon, 09 Oct 2017 22:55:52 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id x2si8506836pfk.436.2017.10.09.22.55.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Oct 2017 22:55:51 -0700 (PDT)
Subject: Re: [PATCH v3] mm, sysctl: make NUMA stats configurable
References: <1506579101-5457-1-git-send-email-kemi.wang@intel.com>
 <20171003092352.2wh2jbtt2dudfi5a@dhcp22.suse.cz>
 <221a1e93-ee33-d598-67de-d6071f192040@intel.com>
 <20171009075549.pzohdnerillwuhqo@dhcp22.suse.cz>
 <20171010054902.sqp6yyid6qqhpsrt@dhcp22.suse.cz>
From: kemi <kemi.wang@intel.com>
Message-ID: <1e3cb07f-84b0-47cd-b3de-542cd2f68320@intel.com>
Date: Tue, 10 Oct 2017 13:54:10 +0800
MIME-Version: 1.0
In-Reply-To: <20171010054902.sqp6yyid6qqhpsrt@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "Luis R . Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Christopher Lameter <cl@linux.com>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Vlastimil Babka <vbabka@suse.cz>, Dave <dave.hansen@linux.intel.com>, Tim Chen <tim.c.chen@intel.com>, Andi Kleen <andi.kleen@intel.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Ying Huang <ying.huang@intel.com>, Aaron Lu <aaron.lu@intel.com>, Proc sysctl <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>



On 2017a1'10ae??10ae?JPY 13:49, Michal Hocko wrote:
> On Mon 09-10-17 09:55:49, Michal Hocko wrote:
>> I haven't checked closely but what happens (or should happen) when you
>> do a partial read? Should you get an inconsistent results? Or is this
>> impossible?
> 
> Well, after thinking about it little bit more, partial reads are always
> inconsistent so this wouldn't add a new problem.
> 
> Anyway I still stand by my position that this sounds over-engineered and
> a simple 0/1 resp. on/off interface would be both simpler and safer. If
> anybody wants an auto mode it can be added later (as a value 2 resp.
> auto).
> 

It sounds good to me. If Andrew also tends to be a simple 0/1, I will submit
V4 patch for it. Thanks

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
