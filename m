Received: by zproxy.gmail.com with SMTP id z3so871105nzf
        for <linux-mm@kvack.org>; Sat, 11 Mar 2006 00:22:45 -0800 (PST)
Message-ID: <661de9470603110022i25baba63w4a79eb543c5db626@mail.gmail.com>
Date: Sat, 11 Mar 2006 13:52:45 +0530
From: "Balbir Singh" <bsingharora@gmail.com>
Subject: Re: [patch 1/3] radix tree: RCU lockless read-side
In-Reply-To: <20060207021831.10002.84268.sendpatchset@linux.site>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
References: <20060207021822.10002.30448.sendpatchset@linux.site>
	 <20060207021831.10002.84268.sendpatchset@linux.site>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

<snip>

>                 if (slot->slots[i]) {
> -                       results[nr_found++] = slot->slots[i];
> +                       results[nr_found++] = &slot->slots[i];
>                         if (nr_found == max_items)
>                                 goto out;
>                 }

A quick clarification - Shouldn't accesses to slot->slots[i] above be
protected using rcu_derefence()?

Warm Regards,
Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
