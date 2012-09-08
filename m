Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id A1DB96B00B9
	for <linux-mm@kvack.org>; Sat,  8 Sep 2012 18:30:46 -0400 (EDT)
Date: Sat, 8 Sep 2012 22:30:45 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v2 0/10] mm: SLxB cleaning and trace accuracy
 improvement
In-Reply-To: <CALF0-+VMtUPuLHg3CwDxFm-TjbN1=YavGO79Oo3GuymOLvikeA@mail.gmail.com>
Message-ID: <00000139a801aba3-4616277c-d845-4b62-83ec-1a1950b05751-000000@email.amazonses.com>
References: <CALF0-+VMtUPuLHg3CwDxFm-TjbN1=YavGO79Oo3GuymOLvikeA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ezequiel Garcia <elezegarcia@gmail.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, JoonSoo Kim <js1304@gmail.com>, Tim Bird <tim.bird@am.sony.com>, Steven Rostedt <rostedt@goodmis.org>, David Rientjes <rientjes@google.com>, Glauber Costa <glommer@parallels.com>

On Sat, 8 Sep 2012, Ezequiel Garcia wrote:

> This is the second spin of my patchset to clean SLxB and improve kmem
> trace events accuracy.

Please redo the patches on top of the patchsets that create
mm/slab_common.c. You will be able to extract a lot more common code and
help the goal of having as much common code as possible. PLease move as
much as possible of the common functions into slab_common.c

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
