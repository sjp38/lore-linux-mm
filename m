From: Alistair J Strachan <alistair@devzero.co.uk>
Subject: Re: 2.6.0-test5-mm4
Date: Mon, 22 Sep 2003 14:54:16 +0100
References: <20030922013548.6e5a5dcf.akpm@osdl.org> <20030922143605.GA9961@gemtek.lt> <200309221449.37677.alistair@devzero.co.uk>
In-Reply-To: <200309221449.37677.alistair@devzero.co.uk>
MIME-Version: 1.0
Content-Disposition: inline
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <200309221454.16116.alistair@devzero.co.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Zilvinas Valinskas <zilvinas@gemtek.lt>
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Monday 22 September 2003 14:49, Alistair J Strachan wrote:
[snip]
>
> I'll try that, thanks. But I have this in lilo.conf:
>
> boot=/dev/discs/disc0/disc
> root=/dev/discs/disc0/part2
>
> /dev/discs is indeed a symlink, but it should be resolved when LILO is
> installed, i.e., prior to the reboot. Why has this behaviour changed?
>

Changing it as per your suggestion makes no difference. I still cannot boot, 
and the error is identical.

Disregard my last email.

Cheers,
Alistair.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
