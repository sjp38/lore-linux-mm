Message-Id: <200107280239.f6S2d5d08748@maila.telia.com>
Content-Type: text/plain;
  charset="iso-8859-1"
From: Roger Larsson <roger.larsson@norran.net>
Subject: Re: [PATCH] MAX_READAHEAD gives doubled throuput
Date: Sat, 28 Jul 2001 04:29:32 +0200
References: <200107280144.DAA25730@mailb.telia.com> <0107280408170Z.00285@starship>
In-Reply-To: <0107280408170Z.00285@starship>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@bonn-fries.net>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Saturdayen den 28 July 2001 04:08, Daniel Phillips wrote:
> [- - -]
> Wheeeeee!  Out of interest, what are the numbers for 2.4.7 vs
> 2.4.8-pre1 ?
>

Ok, time for a table... (all but dbench are best of 3 with source and 
destination files bigger than memory, dbench is only run once)

		write	copy	read	diff	dbench
2.4.0		32.2	16.4	29.7	15.4	32.9
2.4.4		33.2	15.8	29.8	-	-
2.4.6-pre1+s-irq	33.0	15.6	29.5	11.0	38.9
2.4.7		32.8	16.1	29.4	10.9	32.9
2.4.8-pre1	33.2	16.4	29.5	11.2	26.1
2.4.8-pre1+MRA	30.3	28.3	29.8	28.4	34.8
		
/RogerL
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
