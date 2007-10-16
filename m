Date: Tue, 16 Oct 2007 10:53:13 +0200 (CEST)
From: Jan Engelhardt <jengelh@computergmbh.de>
Subject: Re: [patch][rfc] rewrite ramdisk
In-Reply-To: <200710161826.55834.nickpiggin@yahoo.com.au>
Message-ID: <Pine.LNX.4.64.0710161052380.10197@fbirervta.pbzchgretzou.qr>
References: <200710151028.34407.borntraeger@de.ibm.com>
 <200710161807.41157.nickpiggin@yahoo.com.au>
 <Pine.LNX.4.64.0710161015310.10197@fbirervta.pbzchgretzou.qr>
 <200710161826.55834.nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, Andrew Morton <akpm@linux-foundation.org>, Christian Borntraeger <borntraeger@de.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Theodore Ts'o <tytso@mit.edu>
List-ID: <linux-mm.kvack.org>

On Oct 16 2007 18:26, Nick Piggin wrote:
>> >> It also does not seem needed, since it did not exist before.
>> >> It should go, you can set the variable with brd.rd_nr=XXX (same
>> >> goes for ramdisk_size).
>> >
>> >But only if it's a module?
>>
>> Attributes always work. Try vt.default_red=0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
>> and you will see.
>
>Ah, nice. (I don't use them much!). Still, backward compat I
>think is needed if we are to replace rd.c.
>
Like I said, I did not see rd_nr in Documentation/kernel-parameters.txt
so I thought there was no compat.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
