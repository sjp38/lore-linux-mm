Subject: Re: 2.4.14 + Bug in swap_out.
References: <m1vgg41x3x.fsf@frodo.biederman.org>
	<20011120.222920.51691672.davem@redhat.com>
From: ebiederm@xmission.com (Eric W. Biederman)
Date: 20 Nov 2001 23:37:03 -0700
In-Reply-To: <20011120.222920.51691672.davem@redhat.com>
Message-ID: <m1lmh01vg0.fsf@frodo.biederman.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "David S. Miller" <davem@redhat.com>
Cc: torvalds@transmeta.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

"David S. Miller" <davem@redhat.com> writes:

> I do not agree with your analysis.

Neither do I now but not for your reasons :)

I looked again we are o.k. but just barely.  mmput explicitly checks
to see if it is freeing the swap_mm, and fixes if we are.  It is a
nasty interplay with the swap_mm global, but the code is correct.

My apologies for freaking out I but I couldn't imagine mmput doing
something like that.

Eric
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
