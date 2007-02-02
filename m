Received: by ug-out-1314.google.com with SMTP id s2so672002uge
        for <linux-mm@kvack.org>; Thu, 01 Feb 2007 23:20:08 -0800 (PST)
Message-ID: <84144f020702012320j314568dex748f3e6362cd70e0@mail.gmail.com>
Date: Fri, 2 Feb 2007 09:20:06 +0200
From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: [PATCH] Use parameter passed to cache_reap to determine pointer to work structure
In-Reply-To: <Pine.LNX.4.64.0702011512250.7969@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <Pine.LNX.4.64.0702011512250.7969@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@osdl.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/2/07, Christoph Lameter <clameter@sgi.com> wrote:
> Use the pointer passed to cache_reap to determine the work
> pointer and consolidate exit paths.

Looks good to me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
