Message-ID: <43CD2FDF.8080006@shadowen.org>
Date: Tue, 17 Jan 2006 17:56:47 +0000
From: Andy Whitcroft <apw@shadowen.org>
MIME-Version: 1.0
Subject: Re: [PATCH] zonelists gfp_zone() is really gfp_zonelist()
References: <20060117155010.GA16135@shadowen.org> <1137519100.5526.11.camel@localhost.localdomain>
In-Reply-To: <1137519100.5526.11.camel@localhost.localdomain>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Dave Hansen wrote:

> Hmm, but it's not really a zonelist, either.  It's an index into an
> array of zonelists that gets you a zonelist.  How about
> gfp_to_zonelist_nr()?

Sounds fair, I'll respin the patch with a better name.

-apw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
