Date: Thu, 17 Oct 2002 10:14:31 +0200
From: Zilvinas Valinskas <zilvinas@gemtek.lt>
Subject: Re: 2.5.43-mm1: KDE (3.1 beta2) do not start anymore
Message-ID: <20021017081431.GA16028@gemtek.lt>
Reply-To: Zilvinas Valinskas <zilvinas@gemtek.lt>
References: <200210162327.53701.Dieter.Nuetzel@hamburg.de> <20021016225043.4A3732FBBA@oscar.casa.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20021016225043.4A3732FBBA@oscar.casa.dyndns.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
Cc: Dieter N?tzel <Dieter.Nuetzel@hamburg.de>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, Oct 16, 2002 at 06:50:43PM -0400, Ed Tomlinson wrote:
> Dieter N?tzel wrote:
> 
> > Nothing in the logs.
> > But maybe (short before) sound initialization.
> > Could it be "shared page table" related, too?
> > 
> > W'll try that tomorrow.
> 
> Kde 3.0 has never been able to start here when shared page tables have
> been enabled in an mm kernel.  Still some cleanups and debugging to do 
> it would seem.

I do use 2.4.43-mm1 (with shared pte enabled) - it boots just fine here.

> 
> Ed Tomlinson
> -
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
