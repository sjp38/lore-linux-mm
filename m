Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 894CF6B005A
	for <linux-mm@kvack.org>; Thu,  6 Sep 2012 11:04:26 -0400 (EDT)
Received: by iagk10 with SMTP id k10so2652848iag.14
        for <linux-mm@kvack.org>; Thu, 06 Sep 2012 08:04:25 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <000001399bf23209-1d91226b-87ea-43cf-b482-100ee4d032b1-000000@email.amazonses.com>
References: <1346885323-15689-1-git-send-email-elezegarcia@gmail.com>
	<1346885323-15689-4-git-send-email-elezegarcia@gmail.com>
	<000001399bf23209-1d91226b-87ea-43cf-b482-100ee4d032b1-000000@email.amazonses.com>
Date: Thu, 6 Sep 2012 12:04:24 -0300
Message-ID: <CALF0-+VYaHNjjv1Y15Do+0G_MJo2SzUGEyvezib29rmeYopUtw@mail.gmail.com>
Subject: Re: [PATCH 4/5] mm, slob: Use only 'ret' variable for both slob
 object and returned pointer
From: Ezequiel Garcia <elezegarcia@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>

Hi Christoph,

On Thu, Sep 6, 2012 at 11:18 AM, Christoph Lameter <cl@linux.com> wrote:
> On Wed, 5 Sep 2012, Ezequiel Garcia wrote:
>
>> There's no need to use two variables, 'ret' and 'm'.
>> This is a minor cleanup patch, but it will allow next patch to clean
>> the way tracing is done.
>
> The compiler will fold those variables into one if possible. No need to
> worry about having multiple declarations.
>

I wasn't worried about size or anything, it's a just a clean-n-prepare patch,
necesarry for the next patch:

"mm, slob: Trace allocation failures consistently"

Could you take a look at it?

Thanks,
Ezequiel.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
