Message-ID: <3FFED73D.8020502@gmx.de>
Date: Fri, 09 Jan 2004 17:30:53 +0100
From: "Prakash K. Cheemplavam" <PrakashKC@gmx.de>
MIME-Version: 1.0
Subject: Re: 2.6.1-mm1
References: <20040109014003.3d925e54.akpm@osdl.org>
In-Reply-To: <20040109014003.3d925e54.akpm@osdl.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

could it be that you took out /or forgot to insterst the work-around for 
nforce2+apic? At least I did a test with cpu disconnect on and booted 
kernel and it hang. (I also couldn't find the work-around in the 
sources.) I remember an earlier mm kernel had that workaround inside.

bye,

Prakash
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
