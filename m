Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 7B3F16B0069
	for <linux-mm@kvack.org>; Wed, 16 Nov 2011 02:12:18 -0500 (EST)
Received: by bke17 with SMTP id 17so240153bke.14
        for <linux-mm@kvack.org>; Tue, 15 Nov 2011 23:12:15 -0800 (PST)
Date: Wed, 16 Nov 2011 09:12:10 +0200 (EET)
From: Pekka Enberg <penberg@kernel.org>
Subject: Re: [Patch] tmpfs: add fallocate support
In-Reply-To: <4EC361C0.7040309@redhat.com>
Message-ID: <alpine.LFD.2.02.1111160911320.2446@tux.localdomain>
References: <1321346525-10187-1-git-send-email-amwang@redhat.com> <CAOJsxLEXbWbEhqX2YfzcQhyLJrY0H2ifCJCvGkoFHZsYAZEMPA@mail.gmail.com> <4EC361C0.7040309@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cong Wang <amwang@redhat.com>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, kay.sievers@vrfy.org

On Wed, 16 Nov 2011, Cong Wang wrote:
>> What's the use case for this?
>
> Systemd needs it, see http://lkml.org/lkml/2011/10/20/275.
> I am adding Kay into Cc.

The post doesn't mention why it needs it, though.

 			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
