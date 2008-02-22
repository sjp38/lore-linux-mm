Message-ID: <47BE7F09.5060706@openvz.org>
Date: Fri, 22 Feb 2008 10:51:37 +0300
From: Pavel Emelyanov <xemul@openvz.org>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] ResCounter: Use read_uint in memory controller
References: <20080221203518.544461000@menage.corp.google.com> <20080221205525.349180000@menage.corp.google.com>
In-Reply-To: <20080221205525.349180000@menage.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: menage@google.com, akpm@linux-foundation.org
Cc: balbir@in.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

menage@google.com wrote:
> Update the memory controller to use read_uint for its
> limit/usage/failcnt control files, calling the new
> res_counter_read_uint() function.
> 
> Signed-off-by: Paul Menage <menage@google.com>

Acked-by: Pavel Emelyanov <xemul@openvz.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
