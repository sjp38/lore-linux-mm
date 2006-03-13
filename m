Received: by zproxy.gmail.com with SMTP id l1so1193235nzf
        for <linux-mm@kvack.org>; Sun, 12 Mar 2006 19:04:53 -0800 (PST)
Message-ID: <661de9470603121904h7e83579boe3b26013f771c0f2@mail.gmail.com>
Date: Mon, 13 Mar 2006 08:34:53 +0530
From: "Balbir Singh" <bsingharora@gmail.com>
Subject: Re: [patch 1/3] radix tree: RCU lockless read-side
In-Reply-To: <44128EDA.6010105@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
References: <20060207021822.10002.30448.sendpatchset@linux.site>
	 <20060207021831.10002.84268.sendpatchset@linux.site>
	 <661de9470603110022i25baba63w4a79eb543c5db626@mail.gmail.com>
	 <44128EDA.6010105@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Nick Piggin <npiggin@suse.de>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On 3/11/06, Nick Piggin <nickpiggin@yahoo.com.au> wrote:
> Balbir Singh wrote:
> > <snip>
> >
> >>                if (slot->slots[i]) {
> >>-                       results[nr_found++] = slot->slots[i];
> >>+                       results[nr_found++] = &slot->slots[i];
> >>                        if (nr_found == max_items)
> >>                                goto out;
> >>                }
> >
> >
> > A quick clarification - Shouldn't accesses to slot->slots[i] above be
> > protected using rcu_derefence()?
> >
>
> I think we're safe here -- this is the _address_ of the pointer.
> However, when dereferencing this address in _gang_lookup,
> I think we do need rcu_dereference indeed.
>

Yes, I saw the address operator, but we still derefence "slots" to get
the address.

> Note that _gang_lookup_slot doesn't do this for us, however --
> the caller must do that when dereferencing the pointer to the
> item (eg. see page_cache_get_speculative in 2/3).

Oh! I did not get that far. Will look at the rest of the series

>
> That said, I'm not 100% sure I have the rcu memory barriers in
> the right places (well I'm sure I don't, given the _gang_lookup
> bug you exposed!).

Hmm... Let me look at rcu_torture module and see if I can figure it
out or read the documentation again.

>
> Thanks,
> Nick
>

Warm Regards,
Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
