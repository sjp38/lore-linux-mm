Date: Mon, 11 Sep 2000 13:12:32 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] Page aging for 2.4.0-test8
In-Reply-To: <20000910214150.A30532@acs.ucalgary.ca>
Message-ID: <Pine.LNX.4.21.0009111311220.21018-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Neil Schemenauer <nascheme@enme.ucalgary.ca>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 10 Sep 2000, Neil Schemenauer wrote:

> This patch adds page aging similar to what was in 2.0.

Please take a look at http://www.surriel.com/patches/

I've been working on a new VM patch which adds page
aging in a somewhat more 'balanced' way. Your idea
/heavily/ penalises libc and executable pages by aging
them more often than anonymous pages...

regards,

Rik
--
"What you're running that piece of shit Gnome?!?!"
       -- Miguel de Icaza, UKUUG 2000

http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
