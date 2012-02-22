Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id A59306B002C
	for <linux-mm@kvack.org>; Wed, 22 Feb 2012 02:08:27 -0500 (EST)
Received: by obbta7 with SMTP id ta7so13023008obb.14
        for <linux-mm@kvack.org>; Tue, 21 Feb 2012 23:08:26 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1329824079-14449-1-git-send-email-glommer@parallels.com>
References: <1329824079-14449-1-git-send-email-glommer@parallels.com>
Date: Wed, 22 Feb 2012 09:08:26 +0200
Message-ID: <CAOJsxLHOM7e2SpFMXrMZf7u5Y59H1eGyPsrKzSj6jyG9KkWsMw@mail.gmail.com>
Subject: Re: [PATCH 0/7] memcg kernel memory tracking
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: cgroups@vger.kernel.org, devel@openvz.org, linux-mm@kvack.org, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>

Hi Glauber,

On Tue, Feb 21, 2012 at 1:34 PM, Glauber Costa <glommer@parallels.com> wrote:
> This is a first structured approach to tracking general kernel
> memory within the memory controller. Please tell me what you think.

I like it! I only skimmed through the SLUB changes but they seemed
reasonable enough. What kind of performance hit are we taking when
memcg configuration option is enabled but the feature is disabled?

                        Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
