Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id 5013F6B0088
	for <linux-mm@kvack.org>; Mon, 16 Jul 2012 14:05:26 -0400 (EDT)
Date: Mon, 16 Jul 2012 13:05:22 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 1/3] mm: correct return value of migrate_pages()
In-Reply-To: <CAAmzW4OS7=xfm0shxsi0k8kJ=2oNs4MQAEJ=EJv_xRydrukF1w@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1207161302560.32319@router.home>
References: <1342455272-32703-1-git-send-email-js1304@gmail.com> <874np7r4ee.fsf@erwin.mina86.com> <CAAmzW4OS7=xfm0shxsi0k8kJ=2oNs4MQAEJ=EJv_xRydrukF1w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: JoonSoo Kim <js1304@gmail.com>
Cc: Michal Nazarewicz <mina86@tlen.pl>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 17 Jul 2012, JoonSoo Kim wrote:

> > Actually, it makes me wonder if there is any code that uses this
> > information.  If not, it would be best in my opinion to make it return
> > zero or negative error code, but that would have to be checked.
>
> I think that, too.
> I looked at every callsites for migrate_pages() and there is no place
> which really need fail count.
> This function sometimes makes caller error-prone,
> so I think changing return value is preferable.
>
> How do you think, Christoph?

We could do that. I am not aware of anything using that information
either. However, the condition in which some pages where migrated and
others are not is not like a classic error. In many situations the moving
of the pages is done for performance reasons. This just means that the
best performant memory locations could not be used for some pages. A
situation like that may be ok for an application.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
