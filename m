Date: Wed, 26 Feb 2003 10:24:32 -0800
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: [PATCH 2.5.62-mm3] objrmap fix for X
Message-ID: <16000000.1046283871@[10.10.2.4]>
In-Reply-To: <200302261903.17122.m.c.p@wolk-project.de>
References: <20030223230023.365782f3.akpm@digeo.com>
 <40780000.1046240068@[10.10.2.4]> <14910000.1046281932@[10.10.2.4]>
 <200302261903.17122.m.c.p@wolk-project.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marc-Christian Petersen <m.c.p@wolk-project.de>, Dave McCracken <dmccr@us.ibm.com>, Andrew Morton <akpm@digeo.com>
Cc: zilvinas@gemtek.lt, helgehaf@aitel.hist.no, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>> Pah. Debian stealth-upgraded me to gcc 3.2 ... no wonder it's slow as a
>> dog. So your patch is stable, and works just fine. Sorry,
> hmm, you mean gcc 3.2 compilations are slow as dog? gcc 2.95.x is better?

Yeah, about 1.5x difference. See the whole thread on that where I posted
more numbers a week or two ago (though that bit was right down at the end
of the first email, IIRC).

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
