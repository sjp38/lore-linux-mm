Received: by wr-out-0506.google.com with SMTP id 60so1893810wri.8
        for <linux-mm@kvack.org>; Tue, 05 Feb 2008 01:48:10 -0800 (PST)
Message-ID: <804dabb00802050148l3b379016we5fc54f326121276@mail.gmail.com>
Date: Tue, 5 Feb 2008 17:48:08 +0800
From: "Peter Teoh" <htmldeveloper@gmail.com>
Subject: git-pull conflict - how to solve it?
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, "kernelnewbies@nl.linux.org" <kernelnewbies@nl.linux.org>
List-ID: <linux-mm.kvack.org>

After I issued "git pull" I got the following conflicts:

remote: Counting objects: 3463, done.
remote: Compressing objects: 100% (459/459), done.
Indexing 2612 objects...
remote: Total 2612 (delta 2236), reused 2528 (delta 2152)
 100% (2612/2612) done
Resolving 2236 deltas...
 100% (2236/2236) done
718 objects were added to complete this thin pack.
* refs/remotes/origin/master: fast forward to branch 'master' of
git://git.kernel.org/pub/scm/linux/kernel/git/x86/linux-2.6-x86
  old..new: 795d45b..5329cf8
* refs/remotes/origin/mm: forcing update to non-fast forward branch
'mm' of git://git.kernel.org/pub/scm/linux/kernel/git/x86/linux-2.6-x86
  old...new: b7e245f...1c207e8
Removed Documentation/smp.txt
Removed arch/arm/Kconfig.instrumentation
Removed arch/arm/mach-ixp4xx/dsmg600-power.c
Removed arch/arm/mach-ixp4xx/nas100d-power.c
Removed arch/arm/mach-ixp4xx/nslu2-power.c
Auto-merged arch/x86/Kconfig
Auto-merged arch/x86/mm/ioremap.c
CONFLICT (content): Merge conflict in arch/x86/mm/ioremap.c
Removed drivers/net/mipsnet.h
Removed drivers/pci/pcie/aspm.c
Removed include/linux/aspm.h
Removed kernel/Kconfig.instrumentation
Automatic merge failed; fix conflicts and then commit the result.

I really don't know what happens?   Please help me, thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
