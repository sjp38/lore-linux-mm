Received: by wx-out-0506.google.com with SMTP id h31so2351914wxd.11
        for <linux-mm@kvack.org>; Tue, 05 Feb 2008 02:16:55 -0800 (PST)
Message-ID: <804dabb00802050216y50d1dfcasf8d5cdcf466ea58d@mail.gmail.com>
Date: Tue, 5 Feb 2008 18:16:54 +0800
From: "Peter Teoh" <htmldeveloper@gmail.com>
Subject: Re: git-pull conflict - how to solve it?
In-Reply-To: <804dabb00802050148l3b379016we5fc54f326121276@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <804dabb00802050148l3b379016we5fc54f326121276@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, "kernelnewbies@nl.linux.org" <kernelnewbies@nl.linux.org>
List-ID: <linux-mm.kvack.org>

I suspect the git source is having some problem.   Because after I
deleted the file, did a git checkout -f again, the ioremap.c comes
back with the corrupted contents.

--- ioremap.c   2008-02-05 11:01:45.000000000 +0800
+++ /tmp/ioremap.c      2008-02-05 17:37:12.000000000 +0800
@@ -103,6 +103,10 @@ static void __iomem *__ioremap(unsigned
 {
        unsigned long pfn, offset, last_addr, vaddr;
        struct vm_struct *area;
+<<<<<<< HEAD:arch/x86/mm/ioremap.c
+       unsigned long pfn, offset, last_addr;
+=======
+>>>>>>> 5329cf8e19bd83f8d9e0b6b2a3cdcfbd288eb68e:arch/x86/mm/ioremap.c
        pgprot_t prot;

        /* Don't allow wraparound or zero size */
@@ -121,8 +125,12 @@ static void __iomem *__ioremap(unsigned
         */
        for (pfn = phys_addr >> PAGE_SHIFT; pfn < max_pfn_mapped &&
             (pfn << PAGE_SHIFT) < last_addr; pfn++) {
+<<<<<<< HEAD:arch/x86/mm/ioremap.c
+               if (pfn_valid(pfn) && !PageReserved(pfn_to_page(pfn)))
+=======
                if (page_is_ram(pfn) && pfn_valid(pfn) &&
                    !PageReserved(pfn_to_page(pfn)))
+>>>>>>> 5329cf8e19bd83f8d9e0b6b2a3cdcfbd288eb68e:arch/x86/mm/ioremap.c
                        return NULL;
        }

where is diff is wrt to linus-tree.

Therefore, I copied over the ioremap.c from linus tree and continued
my compilation.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
