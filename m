Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id 6A04A6B0032
	for <linux-mm@kvack.org>; Tue, 18 Jun 2013 02:35:17 -0400 (EDT)
Received: by mail-lb0-f176.google.com with SMTP id z5so3206871lbh.21
        for <linux-mm@kvack.org>; Mon, 17 Jun 2013 23:35:15 -0700 (PDT)
Message-ID: <51BFFFA1.8030402@kernel.org>
Date: Tue, 18 Jun 2013 09:35:13 +0300
From: Pekka Enberg <penberg@kernel.org>
MIME-Version: 1.0
Subject: Re: [3.11 1/4] slub: Make cpu partial slab support configurable V2
References: <20130614195500.373711648@linux.com> <0000013f44418a14-7abe9784-a481-4c34-8ff3-c3afe2d57979-000000@email.amazonses.com>
In-Reply-To: <0000013f44418a14-7abe9784-a481-4c34-8ff3-c3afe2d57979-000000@email.amazonses.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Joonsoo Kim <js1304@gmail.com>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

On 06/14/2013 10:55 PM, Christoph Lameter wrote:
> cpu partial support can introduce level of indeterminism that is not wanted
> in certain context (like a realtime kernel). Make it configurable.
>
> Signed-off-by: Christoph Lameter <cl@linux.com>

The changelog is way too vague. Numbers? Anyone who would want to
use this in real world scenarios, please speak up!

			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
