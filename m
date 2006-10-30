Received: by ug-out-1314.google.com with SMTP id o4so1053805uge
        for <linux-mm@kvack.org>; Mon, 30 Oct 2006 07:47:18 -0800 (PST)
Message-ID: <84144f020610300747q2652e185u6499510659a54a8c@mail.gmail.com>
Date: Mon, 30 Oct 2006 17:47:18 +0200
From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: Re: Slab panic on 2.6.19-rc3-git5 (-git4 was OK)
In-Reply-To: <45461BC7.5050609@shadowen.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <454442DC.9050703@google.com>
	 <20061029000513.de5af713.akpm@osdl.org>
	 <4544E92C.8000103@shadowen.org> <4545325D.8080905@mbligh.org>
	 <Pine.LNX.4.64.0610291718481.25218@g5.osdl.org>
	 <45461BC7.5050609@shadowen.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: Linus Torvalds <torvalds@osdl.org>, "Martin J. Bligh" <mbligh@mbligh.org>, Andrew Morton <akpm@osdl.org>, "Martin J. Bligh" <mbligh@google.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On 10/30/06, Andy Whitcroft <apw@shadowen.org> wrote:
> Test results are back on the version of the slab panic fix which Linus'
> has committed in his tree.  This change on top of 2.6.19-rc3-git5 is
> good.  2.6.19-rc3-git6 is also showing good on this machine.

FWIW, the patch looks correct to me also.

                           Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
