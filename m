Date: Thu, 8 Jun 2000 11:40:08 -0600
From: Neil Schemenauer <nascheme@enme.ucalgary.ca>
Subject: Re: Size of mem_map array?
Message-ID: <20000608114008.B1253@acs.ucalgary.ca>
References: <20000608174036Z131165-281+93@kanga.kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20000608174036Z131165-281+93@kanga.kvack.org>; from ttabi@interactivesi.com on Thu, Jun 08, 2000 at 12:17:17PM -0500
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Timur Tabi <ttabi@interactivesi.com>
Cc: Linux MM mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, Jun 08, 2000 at 12:17:17PM -0500, Timur Tabi wrote:
> I've scoured the 2.3 kernel source code, but can't find
> Ianything.

The length of the array is max_mapnr.  The size of the elements
are sizeof(struct page).

    Neil

-- 
python -c "f=lambda n:n and f(n/128)+chr(n%128) or '';print f(0x13b2\
e9d8829e3d1976e5dd87ae5e481e6ec3cf1e8cbb72c0eb8f0eccf879795d8f0bel)"
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
