Received: from burns.conectiva (burns.conectiva [10.0.0.4])
	by perninha.conectiva.com.br (Postfix) with SMTP id B51D338CAA
	for <linux-mm@kvack.org>; Mon, 23 Jul 2001 15:46:01 -0300 (EST)
Date: Mon, 23 Jul 2001 15:46:00 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: Swap progress accounting
In-Reply-To: <20010723194153.J31712@redhat.com>
Message-ID: <Pine.LNX.4.33L.0107231545360.20326-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Arjan van de Ven <arjanv@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 23 Jul 2001, Stephen C. Tweedie wrote:

> That's very much the sort of thing that the reservation proposal from
> a few weeks back was designed to address --- serialising access to the
> last few free pages to allow the VM to proceed OK.

Fully agreed.  We need reservations to properly fix this issue.

Rik
--
Executive summary of a recent Microsoft press release:
   "we are concerned about the GNU General Public License (GPL)"


		http://www.surriel.com/
http://www.conectiva.com/	http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
