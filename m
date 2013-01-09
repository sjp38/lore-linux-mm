Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id CF8D56B005A
	for <linux-mm@kvack.org>; Tue,  8 Jan 2013 20:32:06 -0500 (EST)
Received: by mail-vb0-f50.google.com with SMTP id ft2so1068073vbb.23
        for <linux-mm@kvack.org>; Tue, 08 Jan 2013 17:32:05 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1357694895-520-1-git-send-email-walken@google.com>
References: <1357694895-520-1-git-send-email-walken@google.com>
Date: Tue, 8 Jan 2013 17:32:05 -0800
Message-ID: <CANN689EMBPqVCZdTZm1G0PznGpYR6Y5tMUOspE+emHaX=TkVtA@mail.gmail.com>
Subject: Re: [PATCH 0/8] vm_unmapped_area: finish the mission
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, "James E.J. Bottomley" <jejb@parisc-linux.org>, Matt Turner <mattst88@gmail.com>, David Howells <dhowells@redhat.com>, Tony Luck <tony.luck@intel.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, linux-parisc@vger.kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org

Whoops, I was supposed to find a more appropriate subject line before
sending this :]

On Tue, Jan 8, 2013 at 5:28 PM, Michel Lespinasse <walken@google.com> wrote:
> These patches, which apply on top of v3.8-rc kernels, are to complete the
> VMA gap finding code I introduced (following Rik's initial proposal) in
> v3.8-rc1.

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
