Date: Thu, 16 May 2002 17:24:32 +0530 (IST)
From: Sanket Rathi <sanket.rathi@cdac.ernet.in>
In-Reply-To: <20020510105545.A3297@redhat.com>
Message-ID: <Pine.GSO.4.10.10205161639280.24920-100000@mailhub.cdac.ernet.in>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.rutgers.edu, kernel-doc@nl.linux.org
List-ID: <linux-mm.kvack.org>

I just want to know how can we restrict the maximum virtual memory and
maximum physical memory on ia64 platform.
Is there any settings in kernel so that we can change that and recompile
kernel. Actually we have a device which can only access 44 bits so we cant
have 64 bit address. I mean is it possible to discard some bits which are
not significant.

Tell me something related to this or any link which i can refer 

Thanks in advance

--- Sanket Rathi


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
