Date: Thu, 13 Jun 2002 17:45:26 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: slab cache
Message-ID: <20020613174526.F9286@redhat.com>
References: <3D036BBE.4030603@shaolinmicro.com> <20020610095750.B2571@redhat.com> <3D076339.1070301@shaolinmicro.com> <20020612162941.M12834@redhat.com> <3D08C984.3010308@shaolinmicro.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3D08C984.3010308@shaolinmicro.com>; from davidchow@shaolinmicro.com on Fri, Jun 14, 2002 at 12:34:12AM +0800
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Chow <davidchow@shaolinmicro.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Fri, Jun 14, 2002 at 12:34:12AM +0800, David Chow wrote:

> Thanks for comment, since you mention about cache, do you mean CPU L2 
> caches? I don't use to dynamic alloc and dealloc pages, I have a fixed 
> sized cache per CPU, even using vmalloc I will only do it only once 
> during module initialize, and dealloc only on unload, 

In that case, slab won't have anything to offer you over basic use of
get_free_pages().

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
