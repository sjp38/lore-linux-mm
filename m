From: Daniel Phillips <phillips@istop.com>
Subject: Re: [RFC][PATCH] Rename PageChecked as PageMiscFS
Date: Fri, 12 Aug 2005 13:29:46 +1000
References: <200508110812.59986.phillips@arcor.de> <20050808145430.15394c3c.akpm@osdl.org> <26569.1123752390@warthog.cambridge.redhat.com>
In-Reply-To: <26569.1123752390@warthog.cambridge.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200508121329.46533.phillips@istop.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Howells <dhowells@redhat.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Thursday 11 August 2005 19:26, David Howells wrote:
> Daniel Phillips <phillips@arcor.de> wrote:
> > +	SetPageMiscFS(page);
>
> Can you please retain the *PageFsMisc names I've been using in my stuff?
>
> In my opinion putting the "Fs" bit first gives a clearer indication that
> this is a bit exclusively for the use of filesystems in general.

You also achieved some sort of new low point in the abuse of StudlyCaps there. 
Please, let's not get started on mixed case acronyms.

Anyway, it sounds like you want to bless the use of private page flags in 
filesystems.  That is most probably a bad idea.  Take a browse through the 
existing users and feast your eyes on the spectacular lack of elegance.

Regards,

Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
