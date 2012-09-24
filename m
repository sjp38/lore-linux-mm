Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id D67286B002B
	for <linux-mm@kvack.org>; Mon, 24 Sep 2012 13:11:29 -0400 (EDT)
Received: by ied10 with SMTP id 10so14436173ied.14
        for <linux-mm@kvack.org>; Mon, 24 Sep 2012 10:11:29 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CALF0-+WgbNFKx9COpURq5JGgB06yXraTOEE9Yf4ntjvx_tWaGQ@mail.gmail.com>
References: <1346753637-13389-1-git-send-email-elezegarcia@gmail.com>
	<5045D4B9.9000909@parallels.com>
	<CALF0-+WZhY5NOYiEdDR2n_JrCKB70jei55pEw=914aSWmeqhNg@mail.gmail.com>
	<5045E0ED.1000402@parallels.com>
	<000001399270c7b4-b991895b-5754-4863-8009-c49996628cbb-000000@email.amazonses.com>
	<CALF0-+WgbNFKx9COpURq5JGgB06yXraTOEE9Yf4ntjvx_tWaGQ@mail.gmail.com>
Date: Mon, 24 Sep 2012 14:11:28 -0300
Message-ID: <CALF0-+X65HCRurf5gvqd2Y2qWyn8o08qxi+bW9h2J2GsCAwOyQ@mail.gmail.com>
Subject: Re: [PATCH v2] mm, slob: Drop usage of page->private for storing
 page-sized allocations
From: Ezequiel Garcia <elezegarcia@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, Christoph Lameter <cl@linux.com>, Matt Mackall <mpm@selenic.com>

Pekka,

On Wed, Sep 5, 2012 at 11:11 AM, Ezequiel Garcia <elezegarcia@gmail.com> wrote:
> On Tue, Sep 4, 2012 at 3:00 PM, Christoph Lameter <cl@linux.com> wrote:
>> I thought I acked it before?
>>
>> Acked-by: Christoph Lameter <cl@linux.com>
>>
>

Will you pick this for v3.7 pull request?
Or is there anything wrong with it?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
