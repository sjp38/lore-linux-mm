Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id BEF4E6B009B
	for <linux-mm@kvack.org>; Wed,  5 Sep 2012 20:59:32 -0400 (EDT)
Received: by dadi14 with SMTP id i14so786503dad.14
        for <linux-mm@kvack.org>; Wed, 05 Sep 2012 17:59:32 -0700 (PDT)
Date: Wed, 5 Sep 2012 17:59:29 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 3/5] mm, util: Do strndup_user allocation directly,
 instead of through memdup_user
In-Reply-To: <1346885323-15689-3-git-send-email-elezegarcia@gmail.com>
Message-ID: <alpine.DEB.2.00.1209051757250.7625@chino.kir.corp.google.com>
References: <1346885323-15689-1-git-send-email-elezegarcia@gmail.com> <1346885323-15689-3-git-send-email-elezegarcia@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ezequiel Garcia <elezegarcia@gmail.com>
Cc: linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>

On Wed, 5 Sep 2012, Ezequiel Garcia wrote:

> I'm not sure this is the best solution,
> but creating another function to reuse between strndup_user
> and memdup_user seemed like an overkill.
> 

It's not, so you'd need to do two things to fix this:

 - provide a reason why strndup_user() is special compared to other 
   common library functions that also allocate memory, and

 - provide a __stndup_user() to pass the _RET_IP_.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
