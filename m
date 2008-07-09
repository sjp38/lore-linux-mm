Message-ID: <2323.10.16.10.158.1215617532.squirrel@mail.serc.iisc.ernet.in>
In-Reply-To: <4874D232.800@linux-foundation.org>
References: <2206.10.16.10.158.1215613660.squirrel@mail.serc.iisc.ernet.in>
    <4874CAE7.80600@linux-foundation.org>
    <2282.10.16.10.158.1215615048.squirrel@mail.serc.iisc.ernet.in>
    <4874D232.800@linux-foundation.org>
Date: Wed, 9 Jul 2008 21:02:12 +0530 (IST)
Subject: [Bug]: Oops on ppc64 2.6.5-7.244-pseries64 in mm/objrmap.c
From: kiran@serc.iisc.ernet.in
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

No, since the machines are in production, we cannot change OS. If it
surely solves the problem we can upgrade.

Any information,can we get from the call traces which i have sent...?
Any where this same problem reported?


> kiran@serc.iisc.ernet.in wrote:
>> Currently we don't have support from Novell.
>> Is it a bug or hardware error? Please help us.
>
> Can you reproduce the problem with 2.6.26-rc9?
>
> --
> This message has been scanned for viruses and
> dangerous content by MailScanner, and is
> believed to be clean.
>
>



-- 
This message has been scanned for viruses and
dangerous content by MailScanner, and is
believed to be clean.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
