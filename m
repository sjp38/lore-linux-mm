From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH 1/7] Modules: Fold percpu_modcopy into module.c
Date: Sat, 19 Jan 2008 06:46:25 +1100
References: <20080118182953.748071000@sgi.com> <20080118182953.922370000@sgi.com>
In-Reply-To: <20080118182953.922370000@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200801190646.25817.rusty@rustcorp.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: travis@sgi.com
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>, mingo@elte.hu, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Saturday 19 January 2008 05:29:54 travis@sgi.com wrote:
> percpu_modcopy() is defined multiple times in arch files. However, the only
> user is module.c. Put a static definition into module.c and remove
> the definitions from the arch files.

Acked-by: Rusty Russell <rusty@rustcorp.com.au>

Thanks!
Rusty.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
