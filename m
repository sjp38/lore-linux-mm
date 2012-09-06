Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id AFEB66B0096
	for <linux-mm@kvack.org>; Wed,  5 Sep 2012 20:54:45 -0400 (EDT)
Received: by dadi14 with SMTP id i14so784343dad.14
        for <linux-mm@kvack.org>; Wed, 05 Sep 2012 17:54:45 -0700 (PDT)
Date: Wed, 5 Sep 2012 17:54:41 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/5] mm, slab: Remove silly function slab_buffer_size()
In-Reply-To: <1346885323-15689-1-git-send-email-elezegarcia@gmail.com>
Message-ID: <alpine.DEB.2.00.1209051752060.7625@chino.kir.corp.google.com>
References: <1346885323-15689-1-git-send-email-elezegarcia@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ezequiel Garcia <elezegarcia@gmail.com>
Cc: linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>

On Wed, 5 Sep 2012, Ezequiel Garcia wrote:

> This function is seldom used, and can be simply replaced with cachep->size.
> 

You didn't remove the declaration of this function in the header file.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
