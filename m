Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id BB6736B0032
	for <linux-mm@kvack.org>; Thu, 16 May 2013 12:27:53 -0400 (EDT)
Date: Thu, 16 May 2013 09:27:46 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC PATCH 0/2] return value from shrinkers
Message-Id: <20130516092746.d838ea18.akpm@linux-foundation.org>
In-Reply-To: <20130516075205.GD24072@caracas.corpusers.net>
References: <1368454595-5121-1-git-send-email-oskar.andero@sonymobile.com>
	<20130515160532.c965e92707c354100e25f79b@linux-foundation.org>
	<20130516075205.GD24072@caracas.corpusers.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oskar Andero <oskar.andero@sonymobile.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Hugh Dickins <hughd@google.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Lekanovic, Radovan" <Radovan.Lekanovic@sonymobile.com>, David Rientjes <rientjes@google.com>, Glauber Costa <glommer@parallels.com>

On Thu, 16 May 2013 09:52:05 +0200 Oskar Andero <oskar.andero@sonymobile.com> wrote:

> > If we want the capability to return more than a binary yes/no message
> > to callers then yes, we could/should enumerate the shrinker return
> > values.  But as that is a different concept from errnos, it should be
> > done with a different and shrinker-specific namespace.
> 
> Agreed, but even if there right now is only a binary return message, is a
> hardcoded -1 considered to be acceptable for an interface? IMHO, it is not
> very readable nor intuitive for the users of the interface. Why not, as you
> mention, add a define or enum in shrinker.h instead, e.g. SHRINKER_STOP or
> something.

That sounds OK to me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
