Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id F278A6B0069
	for <linux-mm@kvack.org>; Wed, 16 Nov 2011 02:16:28 -0500 (EST)
Message-ID: <4EC3633D.6090900@redhat.com>
Date: Wed, 16 Nov 2011 15:16:13 +0800
From: Cong Wang <amwang@redhat.com>
MIME-Version: 1.0
Subject: Re: [Patch] tmpfs: add fallocate support
References: <1321346525-10187-1-git-send-email-amwang@redhat.com> <CAOJsxLEXbWbEhqX2YfzcQhyLJrY0H2ifCJCvGkoFHZsYAZEMPA@mail.gmail.com> <4EC361C0.7040309@redhat.com> <alpine.LFD.2.02.1111160911320.2446@tux.localdomain>
In-Reply-To: <alpine.LFD.2.02.1111160911320.2446@tux.localdomain>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, kay.sievers@vrfy.org

ao? 2011a1'11ae??16ae?JPY 15:12, Pekka Enberg a??e??:
> On Wed, 16 Nov 2011, Cong Wang wrote:
>>> What's the use case for this?
>>
>> Systemd needs it, see http://lkml.org/lkml/2011/10/20/275.
>> I am adding Kay into Cc.
>
> The post doesn't mention why it needs it, though.
>

Right, I should mention this in the changelog. :-/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
