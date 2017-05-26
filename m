Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 609C86B0279
	for <linux-mm@kvack.org>; Fri, 26 May 2017 12:13:23 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id c15so10167712ith.7
        for <linux-mm@kvack.org>; Fri, 26 May 2017 09:13:23 -0700 (PDT)
Received: from mail-io0-x231.google.com (mail-io0-x231.google.com. [2607:f8b0:4001:c06::231])
        by mx.google.com with ESMTPS id w189si2481312ith.3.2017.05.26.09.13.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 May 2017 09:13:22 -0700 (PDT)
Received: by mail-io0-x231.google.com with SMTP id p24so12242935ioi.0
        for <linux-mm@kvack.org>; Fri, 26 May 2017 09:13:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170526155812.gdc6x6pz2howdpjb@node.shutemov.name>
References: <20170525203334.867-1-kirill.shutemov@linux.intel.com>
 <CA+55aFznnXPDxYy5CN6qVU7QJ3Y9hbSf-s2-w0QkaNJuTspGcQ@mail.gmail.com>
 <20170526130057.t7zsynihkdtsepkf@node.shutemov.name> <CA+55aFw2HDHRZTYss2xbSTRAZuS1qAFmKrAXsiMp34ngNapTiw@mail.gmail.com>
 <20170526155812.gdc6x6pz2howdpjb@node.shutemov.name>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 26 May 2017 09:13:20 -0700
Message-ID: <CA+55aFz=S=085qe=a2qBWKLXwD1NC4sxjR_xUd9knVv_a3tSiA@mail.gmail.com>
Subject: Re: [PATCHv1, RFC 0/8] Boot-time switching between 4- and 5-level paging
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, the arch/x86 maintainers <x86@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Fri, May 26, 2017 at 8:58 AM, Kirill A. Shutemov
<kirill@shutemov.name> wrote:
>
> It's in a separate white paper for now:
>
> https://software.intel.com/sites/default/files/managed/2b/80/5-level_paging_white_paper.pdf

Thanks. It didn't show up with "LA57 site:intel.com" with google,
which is how I tried to find it ;)

                 Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
