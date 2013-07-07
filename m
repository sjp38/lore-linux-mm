Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id EBBDE6B0039
	for <linux-mm@kvack.org>; Sun,  7 Jul 2013 12:19:44 -0400 (EDT)
Received: by mail-la0-f44.google.com with SMTP id er20so3209696lab.31
        for <linux-mm@kvack.org>; Sun, 07 Jul 2013 09:19:43 -0700 (PDT)
Message-ID: <51D9951E.4050807@kernel.org>
Date: Sun, 07 Jul 2013 19:19:42 +0300
From: Pekka Enberg <penberg@kernel.org>
MIME-Version: 1.0
Subject: Re: [PATCH] slob: Check for NULL pointer before calling ctor()
References: <1358442826.23211.18.camel@gandalf.local.home> <1360073811.27007.13.camel@gandalf.local.home> <0000013caadd2e2f-3ca39b5e-cc18-4a38-9485-d505a89098af-000000@email.amazonses.com>
In-Reply-To: <0000013caadd2e2f-3ca39b5e-cc18-4a38-9485-d505a89098af-000000@email.amazonses.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Steven Rostedt <rostedt@goodmis.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Matt Mackall <mpm@selenic.com>

On 2/5/13 4:58 PM, Christoph Lameter wrote:
> On Tue, 5 Feb 2013, Steven Rostedt wrote:
>
>> Ping?
>
> Obviously correct.
>
> Acked-by: Christoph Lameter <cl@linux.com>

Applied, thanks a lot!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
