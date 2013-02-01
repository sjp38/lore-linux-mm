Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id 762CC6B0023
	for <linux-mm@kvack.org>; Fri,  1 Feb 2013 05:44:12 -0500 (EST)
Received: by mail-wi0-f177.google.com with SMTP id hm14so411450wib.4
        for <linux-mm@kvack.org>; Fri, 01 Feb 2013 02:44:10 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <0000013c25d61596-bb94c3c3-a974-4ca4-9212-ecab243176ba-000000@email.amazonses.com>
References: <0000013c25d61596-bb94c3c3-a974-4ca4-9212-ecab243176ba-000000@email.amazonses.com>
Date: Fri, 1 Feb 2013 12:44:01 +0200
Message-ID: <CAOJsxLFFc4WfS8bv9zOhBpo6RDCRk7OnCOLVewEY=sAb7YqsGg@mail.gmail.com>
Subject: Re: REN2 [00/13] Sl[auo]b: Renaming etc for -next rebased to 3.8-rc3
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Joonsoo Kim <js1304@gmail.com>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, elezegarcia@gmail.com

On Thu, Jan 10, 2013 at 9:00 PM, Christoph Lameter <cl@linux.com> wrote:
> These are patches that mostly rename variables and rearrange code. The first part has
> been extensively reviewed. Please take as much as possible.
>
> Also some bug fixes and a couple of patches that make allocators use common functions.

Applied, thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
