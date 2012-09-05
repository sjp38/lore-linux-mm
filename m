Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id C69206B0068
	for <linux-mm@kvack.org>; Wed,  5 Sep 2012 10:11:36 -0400 (EDT)
Received: by wibhq4 with SMTP id hq4so155573wib.8
        for <linux-mm@kvack.org>; Wed, 05 Sep 2012 07:11:35 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <000001399270c7b4-b991895b-5754-4863-8009-c49996628cbb-000000@email.amazonses.com>
References: <1346753637-13389-1-git-send-email-elezegarcia@gmail.com>
	<5045D4B9.9000909@parallels.com>
	<CALF0-+WZhY5NOYiEdDR2n_JrCKB70jei55pEw=914aSWmeqhNg@mail.gmail.com>
	<5045E0ED.1000402@parallels.com>
	<000001399270c7b4-b991895b-5754-4863-8009-c49996628cbb-000000@email.amazonses.com>
Date: Wed, 5 Sep 2012 11:11:35 -0300
Message-ID: <CALF0-+WgbNFKx9COpURq5JGgB06yXraTOEE9Yf4ntjvx_tWaGQ@mail.gmail.com>
Subject: Re: [PATCH v2] mm, slob: Drop usage of page->private for storing
 page-sized allocations
From: Ezequiel Garcia <elezegarcia@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>

On Tue, Sep 4, 2012 at 3:00 PM, Christoph Lameter <cl@linux.com> wrote:
> I thought I acked it before?
>
> Acked-by: Christoph Lameter <cl@linux.com>
>

Yes you did. This is a v2, that I rebased on top of slab/next for Pekka.

Thanks!
Ezequiel.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
