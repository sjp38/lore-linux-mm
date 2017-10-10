Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id E359A6B025E
	for <linux-mm@kvack.org>; Tue, 10 Oct 2017 10:29:33 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id z80so32398524pff.1
        for <linux-mm@kvack.org>; Tue, 10 Oct 2017 07:29:33 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id t190si935708pgb.504.2017.10.10.07.29.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Oct 2017 07:29:32 -0700 (PDT)
Subject: Re: [PATCH v3] mm, sysctl: make NUMA stats configurable
References: <1506579101-5457-1-git-send-email-kemi.wang@intel.com>
 <20171003092352.2wh2jbtt2dudfi5a@dhcp22.suse.cz>
 <221a1e93-ee33-d598-67de-d6071f192040@intel.com>
 <20171009075549.pzohdnerillwuhqo@dhcp22.suse.cz>
 <20171010054902.sqp6yyid6qqhpsrt@dhcp22.suse.cz>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <bb13e610-758e-0fdd-ee65-781b4920f1c6@linux.intel.com>
Date: Tue, 10 Oct 2017 07:29:31 -0700
MIME-Version: 1.0
In-Reply-To: <20171010054902.sqp6yyid6qqhpsrt@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, kemi <kemi.wang@intel.com>
Cc: "Luis R . Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Christopher Lameter <cl@linux.com>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Vlastimil Babka <vbabka@suse.cz>, Tim Chen <tim.c.chen@intel.com>, Andi Kleen <andi.kleen@intel.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Ying Huang <ying.huang@intel.com>, Aaron Lu <aaron.lu@intel.com>, Proc sysctl <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>

On 10/09/2017 10:49 PM, Michal Hocko wrote:
> On Mon 09-10-17 09:55:49, Michal Hocko wrote:
>> I haven't checked closely but what happens (or should happen) when you
>> do a partial read? Should you get an inconsistent results? Or is this
>> impossible?
> Well, after thinking about it little bit more, partial reads are always
> inconsistent so this wouldn't add a new problem.
> 
> Anyway I still stand by my position that this sounds over-engineered and
> a simple 0/1 resp. on/off interface would be both simpler and safer. If
> anybody wants an auto mode it can be added later (as a value 2 resp.
> auto).

0/1 with the default set to the strict, slower mode?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
