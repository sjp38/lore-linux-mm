Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id BA6306B00E7
	for <linux-mm@kvack.org>; Mon, 21 May 2012 18:13:25 -0400 (EDT)
Date: Mon, 21 May 2012 15:13:23 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [tip:perf/uprobes] uprobes, mm, x86: Add the ability to install
 and remove uprobes breakpoints
Message-Id: <20120521151323.f23bd5e9.akpm@linux-foundation.org>
In-Reply-To: <CA+55aFw5ccuvvtyf6iuuw-Finr79ZkPxgCxL5jNvdnX5oMYkgg@mail.gmail.com>
References: <20120209092642.GE16600@linux.vnet.ibm.com>
	<tip-2b144498350860b6ee9dc57ff27a93ad488de5dc@git.kernel.org>
	<20120521143701.74ab2d0b.akpm@linux-foundation.org>
	<CA+55aFw5ccuvvtyf6iuuw-Finr79ZkPxgCxL5jNvdnX5oMYkgg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: mingo@redhat.com, a.p.zijlstra@chello.nl, peterz@infradead.org, anton@redhat.com, rostedt@goodmis.org, tglx@linutronix.de, oleg@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, hpa@zytor.com, jkenisto@us.ibm.com, andi@firstfloor.org, hch@infradead.org, ananth@in.ibm.com, vda.linux@googlemail.com, masami.hiramatsu.pt@hitachi.com, acme@infradead.org, srikar@linux.vnet.ibm.com, sfr@canb.auug.org.au, roland@hack.frob.com, mingo@elte.hu, linux-tip-commits@vger.kernel.org

On Mon, 21 May 2012 15:00:28 -0700
Linus Torvalds <torvalds@linux-foundation.org> wrote:

> On Mon, May 21, 2012 at 2:37 PM, Andrew Morton
> <akpm@linux-foundation.org> wrote:
> >
> > hm, we seem to have conflicting commits between mainline and linux-next.
> > During the merge window. __Again. __Nobody knows why this happens.
> 
> I didn't have my trivial cleanup branches in linux-next, I'm afraid.

Well, it's a broader issue than that.  I often see a large number of
rejects when syncing mainline with linux-next during the merge window. 
Right now:

Documentation/nfc/nfc-hci.txt:<<<<<<< HEAD
Documentation/nfc/nfc-hci.txt:<<<<<<< HEAD
Documentation/nfc/nfc-hci.txt:<<<<<<< HEAD
Documentation/nfc/nfc-hci.txt:<<<<<<< HEAD
Documentation/nfc/nfc-hci.txt:<<<<<<< HEAD
arch/sparc/Kconfig:<<<<<<< HEAD
arch/sparc/include/asm/thread_info_32.h:<<<<<<< HEAD
drivers/net/ethernet/emulex/benet/be.h:<<<<<<< HEAD
drivers/net/ethernet/emulex/benet/be_cmds.c:<<<<<<< HEAD
drivers/net/ethernet/emulex/benet/be_main.c:<<<<<<< HEAD
drivers/net/ethernet/emulex/benet/be_main.c:<<<<<<< HEAD
drivers/net/virtio_net.c:<<<<<<< HEAD
drivers/net/wireless/ath/ath6kl/cfg80211.c:<<<<<<< HEAD
drivers/net/wireless/ath/ath6kl/cfg80211.c:<<<<<<< HEAD
drivers/net/wireless/ath/ath6kl/cfg80211.c:<<<<<<< HEAD
drivers/net/wireless/ath/ath6kl/cfg80211.c:<<<<<<< HEAD
drivers/net/wireless/ath/ath6kl/cfg80211.c:<<<<<<< HEAD
drivers/net/wireless/ath/ath6kl/cfg80211.c:<<<<<<< HEAD
drivers/net/wireless/ath/ath6kl/cfg80211.c:<<<<<<< HEAD
drivers/net/wireless/ath/ath6kl/cfg80211.c:<<<<<<< HEAD
drivers/net/wireless/ath/ath6kl/cfg80211.c:<<<<<<< HEAD
drivers/net/wireless/ath/ath6kl/htc_pipe.c:<<<<<<< HEAD
drivers/net/wireless/ath/ath6kl/htc_pipe.c:<<<<<<< HEAD
drivers/net/wireless/ath/ath6kl/htc_pipe.c:<<<<<<< HEAD
drivers/net/wireless/ath/ath6kl/htc_pipe.c:<<<<<<< HEAD
drivers/net/wireless/ath/ath6kl/usb.c:<<<<<<< HEAD
drivers/net/wireless/ath/ath6kl/usb.c:<<<<<<< HEAD
drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c:<<<<<<< HEAD
drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c:<<<<<<< HEAD
drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c:<<<<<<< HEAD
drivers/net/wireless/brcm80211/brcmfmac/sdio_host.h:<<<<<<< HEAD
drivers/net/wireless/brcm80211/brcmsmac/channel.c:<<<<<<< HEAD
drivers/net/wireless/iwlwifi/iwl-agn-lib.c:<<<<<<< HEAD
drivers/net/wireless/iwlwifi/iwl-agn-lib.c:<<<<<<< HEAD
drivers/net/wireless/iwlwifi/iwl-agn-lib.c:<<<<<<< HEAD
drivers/net/wireless/iwlwifi/iwl-agn-lib.c:<<<<<<< HEAD
drivers/net/wireless/iwlwifi/iwl-agn-lib.c:<<<<<<< HEAD
drivers/net/wireless/iwlwifi/iwl-agn-rxon.c:<<<<<<< HEAD
drivers/net/wireless/iwlwifi/iwl-agn-tx.c:<<<<<<< HEAD
drivers/net/wireless/iwlwifi/iwl-commands.h:<<<<<<< HEAD
drivers/net/wireless/iwlwifi/iwl-commands.h:<<<<<<< HEAD
drivers/net/wireless/iwlwifi/iwl-mac80211.c:<<<<<<< HEAD
drivers/net/wireless/iwlwifi/iwl-power.c:<<<<<<< HEAD
drivers/net/wireless/mwifiex/cfg80211.c:<<<<<<< HEAD
drivers/net/wireless/mwifiex/cfg80211.c:<<<<<<< HEAD
drivers/net/wireless/mwifiex/cfg80211.c:<<<<<<< HEAD
drivers/net/wireless/mwifiex/cfg80211.c:<<<<<<< HEAD
drivers/net/wireless/mwifiex/cfg80211.c:<<<<<<< HEAD
drivers/net/wireless/mwifiex/decl.h:<<<<<<< HEAD
drivers/net/wireless/mwifiex/fw.h:<<<<<<< HEAD
drivers/net/wireless/mwifiex/fw.h:<<<<<<< HEAD
drivers/net/wireless/mwifiex/fw.h:<<<<<<< HEAD
drivers/net/wireless/mwifiex/main.c:<<<<<<< HEAD
drivers/net/wireless/mwifiex/main.c:<<<<<<< HEAD
drivers/net/wireless/mwifiex/main.c:<<<<<<< HEAD
drivers/net/wireless/mwifiex/main.c:<<<<<<< HEAD
drivers/net/wireless/mwifiex/main.h:<<<<<<< HEAD
drivers/net/wireless/mwifiex/main.h:<<<<<<< HEAD
drivers/net/wireless/mwifiex/main.h:<<<<<<< HEAD
drivers/net/wireless/mwifiex/sta_cmd.c:<<<<<<< HEAD
drivers/net/wireless/mwifiex/sta_cmdresp.c:<<<<<<< HEAD
drivers/net/wireless/mwifiex/sta_ioctl.c:<<<<<<< HEAD
drivers/net/wireless/ti/wl12xx/Kconfig:<<<<<<< HEAD
drivers/net/wireless/ti/wlcore/Kconfig:<<<<<<< HEAD
drivers/net/wireless/ti/wlcore/boot.c:<<<<<<< HEAD
drivers/net/wireless/ti/wlcore/boot.c:<<<<<<< HEAD
drivers/net/wireless/ti/wlcore/wlcore.h:<<<<<<< HEAD
drivers/net/wireless/ti/wlcore/wlcore.h:<<<<<<< HEAD
drivers/nfc/pn533.c:<<<<<<< HEAD
fs/nfs/nfs4proc.c:<<<<<<< HEAD
fs/stat.c:<<<<<<< HEAD
include/linux/filter.h:<<<<<<< HEAD
include/net/mac80211.h:<<<<<<< HEAD
include/net/mac80211.h:<<<<<<< HEAD
include/net/nfc/hci.h:<<<<<<< HEAD
include/net/nfc/hci.h:<<<<<<< HEAD
include/net/nfc/nfc.h:<<<<<<< HEAD
include/net/nfc/nfc.h:<<<<<<< HEAD
include/net/nfc/shdlc.h:<<<<<<< HEAD
mm/memory.c:<<<<<<< HEAD
net/ceph/osdmap.c:<<<<<<< HEAD
net/mac80211/agg-tx.c:<<<<<<< HEAD
net/mac80211/agg-tx.c:<<<<<<< HEAD
net/mac80211/ibss.c:<<<<<<< HEAD
net/mac80211/iface.c:<<<<<<< HEAD
net/mac80211/mesh.c:<<<<<<< HEAD
net/mac80211/mesh_plink.c:<<<<<<< HEAD
net/mac80211/mesh_plink.c:<<<<<<< HEAD
net/mac80211/mesh_plink.c:<<<<<<< HEAD
net/mac80211/mesh_plink.c:<<<<<<< HEAD
net/nfc/core.c:<<<<<<< HEAD
net/nfc/core.c:<<<<<<< HEAD
net/nfc/core.c:<<<<<<< HEAD
net/nfc/core.c:<<<<<<< HEAD
net/nfc/core.c:<<<<<<< HEAD
net/nfc/core.c:<<<<<<< HEAD
net/nfc/core.c:<<<<<<< HEAD
net/nfc/core.c:<<<<<<< HEAD
net/nfc/core.c:<<<<<<< HEAD
net/nfc/core.c:<<<<<<< HEAD
net/nfc/core.c:<<<<<<< HEAD
net/nfc/core.c:<<<<<<< HEAD
net/nfc/core.c:<<<<<<< HEAD
net/nfc/core.c:<<<<<<< HEAD
net/nfc/core.c:<<<<<<< HEAD
net/nfc/core.c:<<<<<<< HEAD
net/nfc/core.c:<<<<<<< HEAD
net/nfc/core.c:<<<<<<< HEAD
net/nfc/hci/Kconfig:<<<<<<< HEAD
net/nfc/hci/core.c:<<<<<<< HEAD
net/nfc/hci/core.c:<<<<<<< HEAD
net/nfc/hci/core.c:<<<<<<< HEAD
net/nfc/hci/core.c:<<<<<<< HEAD
net/nfc/hci/core.c:<<<<<<< HEAD
net/nfc/hci/core.c:<<<<<<< HEAD
net/nfc/hci/core.c:<<<<<<< HEAD
net/nfc/hci/shdlc.c:<<<<<<< HEAD
net/nfc/hci/shdlc.c:<<<<<<< HEAD
net/nfc/nci/core.c:<<<<<<< HEAD

and that is typical.  I've never really bothered working out why this
is happening.

I suspect monkey business is afoot.  People are magically finding new
patches or new versions of old patches when the merge window opens up.

Also, some dope has just gone and added sys_numa_mbind() and
sys_numa_tbind() to linux-next, nicely trashing a few things which were
lined up for 3.5-rc1.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
