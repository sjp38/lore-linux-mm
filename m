Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8D4606B025F
	for <linux-mm@kvack.org>; Wed,  9 Aug 2017 09:18:20 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id l2so65357710pgu.2
        for <linux-mm@kvack.org>; Wed, 09 Aug 2017 06:18:20 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id l19si2555932pfa.168.2017.08.09.06.18.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 09 Aug 2017 06:18:19 -0700 (PDT)
From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [PATCH 13/16] perf: Add a speculative page fault sw events
In-Reply-To: <1502202949-8138-14-git-send-email-ldufour@linux.vnet.ibm.com>
References: <1502202949-8138-1-git-send-email-ldufour@linux.vnet.ibm.com> <1502202949-8138-14-git-send-email-ldufour@linux.vnet.ibm.com>
Date: Wed, 09 Aug 2017 23:18:15 +1000
Message-ID: <87lgmsnalk.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>, paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

Laurent Dufour <ldufour@linux.vnet.ibm.com> writes:

> Add new software events to count succeeded and failed speculative page
> faults.
>
> Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
> ---
>  include/uapi/linux/perf_event.h | 2 ++
>  1 file changed, 2 insertions(+)
>
> diff --git a/include/uapi/linux/perf_event.h b/include/uapi/linux/perf_event.h
> index b1c0b187acfe..fbfb03dff334 100644
> --- a/include/uapi/linux/perf_event.h
> +++ b/include/uapi/linux/perf_event.h
> @@ -111,6 +111,8 @@ enum perf_sw_ids {
>  	PERF_COUNT_SW_EMULATION_FAULTS		= 8,
>  	PERF_COUNT_SW_DUMMY			= 9,
>  	PERF_COUNT_SW_BPF_OUTPUT		= 10,
> +	PERF_COUNT_SW_SPF_DONE			= 11,
> +	PERF_COUNT_SW_SPF_FAILED		= 12,

Can't you calculate:

  PERF_COUNT_SW_SPF_FAILED = PERF_COUNT_SW_PAGE_FAULTS - PERF_COUNT_SW_SPF_DONE

ie. do you need a separate event for it?

cheers

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
