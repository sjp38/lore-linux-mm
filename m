Date: Wed, 3 Oct 2001 15:37:21 -0700
From: Mike Fedyk <mfedyk@matchmail.com>
Subject: Re: weird memshared value
Message-ID: <20011003153721.E7266@mikef-linux.matchmail.com>
References: <3BBB7F5F.9040806@brsat.com.br> <20011003143038.B7266@mikef-linux.matchmail.com> <3BBB921D.3080805@brsat.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3BBB921D.3080805@brsat.com.br>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Roberto Orenstein <roberto@brsat.com.br>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Oct 03, 2001 at 07:33:01PM -0300, Roberto Orenstein wrote:
> Hi Mike
> 
> Thanx for the help. Patch applied and problem vanish :)
> 
> 
> regards
> 
> Roberto
> 

Be sure to post that to the list.  We need success reports for these types
of things.

I have yet to test the patch myself.

I was able to reliably reproduce it by setting my ram down to 64mb with no
swap and running mozilla with kde...

Mike
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
