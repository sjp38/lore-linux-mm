Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id C0CAB6B0070
	for <linux-mm@kvack.org>; Wed, 24 Oct 2012 09:36:38 -0400 (EDT)
Date: Wed, 24 Oct 2012 13:36:37 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH for-v3.7 1/2] slub: optimize poorly inlined kmalloc*
 functions
In-Reply-To: <CAOJsxLFay=KhhsuTho3focQ5V90k4sBCNNpyP1v29STsmDG=7Q@mail.gmail.com>
Message-ID: <0000013a92fd2f35-3d28d0e4-3419-4b78-ab29-f529b60a1c65-000000@email.amazonses.com>
References: <1350748093-7868-1-git-send-email-js1304@gmail.com> <CAOJsxLFay=KhhsuTho3focQ5V90k4sBCNNpyP1v29STsmDG=7Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Joonsoo Kim <js1304@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 24 Oct 2012, Pekka Enberg wrote:

> Looks reasonable to me. Christoph, any objections?

I am fine with it. Its going to be short lived because my latest patchset
will do the same. Can we merge this for 3.7?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
