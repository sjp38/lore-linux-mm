Date: Thu, 25 May 2000 17:48:17 -0600
From: Neil Schemenauer <nascheme@enme.ucalgary.ca>
Subject: Re: [patch] page aging and deferred swapping for 2.4.0-test1
Message-ID: <20000525174817.A18487@acs.ucalgary.ca>
References: <Pine.LNX.4.21.0005251936390.7453-100000@duckman.distro.conectiva>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.21.0005251936390.7453-100000@duckman.distro.conectiva>; from riel@conectiva.com.br on Thu, May 25, 2000 at 08:03:42PM -0300
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 25, 2000 at 08:03:42PM -0300, Rik van Riel wrote:
> +		if (PageTestandClearReferenced(page)) {
> +			page->age += 3;
> +			if (page->age > 10)
> +				page->age = 0;

Why this test?  Something like:

    if (page->age < 10) {
        page->age += 3;
    }

makes more sense to me.

    Neil

-- 
'Slashdot, with its uncontrolled content and participants' poor
impulse control, remains Internet culture's answer to "Lord of
the Flies."' - Salon
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
