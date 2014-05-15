Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f49.google.com (mail-qg0-f49.google.com [209.85.192.49])
	by kanga.kvack.org (Postfix) with ESMTP id C10C36B0039
	for <linux-mm@kvack.org>; Thu, 15 May 2014 11:16:42 -0400 (EDT)
Received: by mail-qg0-f49.google.com with SMTP id a108so1931730qge.36
        for <linux-mm@kvack.org>; Thu, 15 May 2014 08:16:42 -0700 (PDT)
Received: from qmta14.emeryville.ca.mail.comcast.net (qmta14.emeryville.ca.mail.comcast.net. [2001:558:fe2d:44:76:96:27:212])
        by mx.google.com with ESMTP id h90si2716306qgh.133.2014.05.15.08.16.41
        for <linux-mm@kvack.org>;
        Thu, 15 May 2014 08:16:42 -0700 (PDT)
Date: Thu, 15 May 2014 10:16:39 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH RFC 3/3] slub: reparent memcg caches' slabs on memcg
 offline
In-Reply-To: <20140515071650.GB32113@esperanza>
Message-ID: <alpine.DEB.2.10.1405151015330.24665@gentwo.org>
References: <cover.1399982635.git.vdavydov@parallels.com> <6eafe1e95d9a934228e9af785f5b5de38955aa6a.1399982635.git.vdavydov@parallels.com> <alpine.DEB.2.10.1405141119320.16512@gentwo.org> <20140515071650.GB32113@esperanza>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: hannes@cmpxchg.org, mhocko@suse.cz, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 15 May 2014, Vladimir Davydov wrote:

> I admit that's far not perfect, because kfree is really a hot path,
> where every byte of code matters, but unfortunately I don't see how we
> can avoid this in case we want slab re-parenting.

Do we even know that all objects in that slab belong to a certain cgroup?
AFAICT the fastpath currently do not allow to make that distinction.

> Again, I'd like to hear from you if there is any point in moving in this
> direction, or I should give up and concentrate on some other approach,
> because you'll never accept it.

I wish you would find some other way to do this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
