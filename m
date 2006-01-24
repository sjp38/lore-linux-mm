Subject: Re: [PATCH/RFC] Shared page tables
From: Arjan van de Ven <arjan@infradead.org>
In-Reply-To: <E3ED10A5FEE08AEEA9094F49@[10.1.1.4]>
References: <A6D73CCDC544257F3D97F143@[10.1.1.4]>
	 <200601240139.46751.ak@suse.de>
	 <200601231853.54948.raybry@mpdtxmail.amd.com>
	 <200601240210.04337.ak@suse.de>
	 <1138086398.2977.19.camel@laptopd505.fenrus.org>
	 <E3ED10A5FEE08AEEA9094F49@[10.1.1.4]>
Content-Type: text/plain
Date: Tue, 24 Jan 2006 15:56:49 +0100
Message-Id: <1138114609.2977.45.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave McCracken <dmccr@us.ibm.com>
Cc: Andi Kleen <ak@suse.de>, Ray Bryant <raybry@mpdtxmail.amd.com>, Robin Holt <holt@sgi.com>, Hugh Dickins <hugh@veritas.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> I thought the main security benefit for randomization of mapped regions was
> for writeable data space anyway.  Isn't text space protected by not being
> writeable?

nope that's not correct.
Aside from stack randomization, randomization is to a large degree
intended to make the return-to-libc kind of attacks harder, by not
giving attackers a fixed address to return to. That's all code, nothing
to do with data.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
