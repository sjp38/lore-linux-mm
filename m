From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH] More informative logging for OOM-killer
Date: Fri, 15 Jun 2007 13:35:16 +0200
References: <4671B1CA.8070908@bzzt.net>
In-Reply-To: <4671B1CA.8070908@bzzt.net>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 8bit
Content-Disposition: inline
Message-Id: <200706151335.16607.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Arnout Engelen <arnouten@bzzt.net>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thursday 14 June 2007 23:23:22 Arnout Engelen wrote:
> +                       // TODO is this a proper upper bound for the
> +                       // length of a commandline?
> +                       char buffer[PAGE_SIZE / sizeof(char)];

That's a 100% guaranteed stack overflow with 4K stacks.

And sizeof(char) is always 1 btw.

-Andi


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
