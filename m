Date: Mon, 31 Mar 2008 08:48:33 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [RFC 8/8] x86_64: Support for new UV apic
Message-ID: <20080331064833.GB29105@one.firstfloor.org>
References: <20080324182122.GA28327@sgi.com> <87abknhzhd.fsf@basil.nowhere.org> <20080325175657.GA6262@sgi.com> <20080326073823.GD3442@elte.hu> <86802c440803301323q5c4bd4f4k1f9bdc1d6b1a0a7b@mail.gmail.com> <20080330210356.GA13383@sgi.com> <20080330211848.GA29105@one.firstfloor.org> <86802c440803301629g6d1b896o27e12ef3c84ded2c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <86802c440803301629g6d1b896o27e12ef3c84ded2c@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yinghai Lu <yhlu.kernel@gmail.com>
Cc: Andi Kleen <andi@firstfloor.org>, Jack Steiner <steiner@sgi.com>, Ingo Molnar <mingo@elte.hu>, tglx@linutronix.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> if the calling path like GET_APIC_ID is keeping checking if it is UV
> box after boot time, that may not good.

I don't think GET_APIC_ID is anywhere on a critical path. As long
as it doesn't lead to code bloat that shouldn't be an issue.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
