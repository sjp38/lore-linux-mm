Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4E5506B0003
	for <linux-mm@kvack.org>; Fri,  2 Feb 2018 01:35:20 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id m22so19392828pfg.15
        for <linux-mm@kvack.org>; Thu, 01 Feb 2018 22:35:20 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id c23-v6si1224846plk.567.2018.02.01.22.35.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Feb 2018 22:35:19 -0800 (PST)
Date: Fri, 2 Feb 2018 14:34:49 +0800
From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH] socket: Provide bounce buffer for constant sized
 put_cmsg()
Message-ID: <201802021425.9b52psTS%fengguang.wu@intel.com>
References: <20180201104143.GA10983@beast>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180201104143.GA10983@beast>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: kbuild-all@01.org, syzbot+e2d6cfb305e9f3911dea@syzkaller.appspotmail.com, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, Eric Biggers <ebiggers3@gmail.com>, james.morse@arm.com, keun-o.park@darkmatter.ae, labbott@redhat.com, linux-mm@kvack.org, mingo@kernel.org

Hi Kees,

I love your patch! Perhaps something to improve:

[auto build test WARNING on linus/master]
[also build test WARNING on v4.15 next-20180201]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

url:    https://github.com/0day-ci/linux/commits/Kees-Cook/socket-Provide-bounce-buffer-for-constant-sized-put_cmsg/20180202-113637
reproduce:
        # apt-get install sparse
        make ARCH=x86_64 allmodconfig
        make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)

>> net/bluetooth/hci_sock.c:1406:17: sparse: incorrect type in initializer (invalid types) @@ expected void _val @@ got void _val @@
   net/bluetooth/hci_sock.c:1406:17: expected void _val
   net/bluetooth/hci_sock.c:1406:17: got void <noident>
>> net/bluetooth/hci_sock.c:1406:17: sparse: expression using sizeof(void)
   In file included from include/linux/compat.h:16:0,
    from include/linux/ethtool.h:17,
    from include/linux/netdevice.h:41,
    from include/net/sock.h:51,
    from include/net/bluetooth/bluetooth.h:29,
    from net/bluetooth/hci_sock.c:32:
   net/bluetooth/hci_sock.c: In function 'hci_sock_cmsg':
   include/linux/socket.h:355:19: error: variable or field '_val' declared void
    _val = 14- ^
   net/bluetooth/hci_sock.c:1406:3: note: in expansion of macro 'put_cmsg'
    put_cmsg(msg, SOL_HCI, HCI_CMSG_TSTAMP, len, data);
    ^~~~~~~~
   include/linux/socket.h:355:26: warning: dereferencing 'void pointer
    _val = 20- ^~~~~~~
   net/bluetooth/hci_sock.c:1406:3: note: in expansion of macro 'put_cmsg'
    put_cmsg(msg, SOL_HCI, HCI_CMSG_TSTAMP, len, data);
    ^~~~~~~~
   include/linux/socket.h:355:26: error: void value not ignored as it ought to be
    _val = 26- ^
   net/bluetooth/hci_sock.c:1406:3: note: in expansion of macro 'put_cmsg'
    put_cmsg(msg, SOL_HCI, HCI_CMSG_TSTAMP, len, data);
    ^~~~~~~~

vim +1406 net/bluetooth/hci_sock.c

767c5eb5 Marcel Holtmann 2007-09-09  1405  
767c5eb5 Marcel Holtmann 2007-09-09 @1406  		put_cmsg(msg, SOL_HCI, HCI_CMSG_TSTAMP, len, data);
a61bbcf2 Patrick McHardy 2005-08-14  1407  	}
^1da177e Linus Torvalds  2005-04-16  1408  }
^1da177e Linus Torvalds  2005-04-16  1409  

:::::: The code at line 1406 was first introduced by commit
:::::: 767c5eb5d35aeb85987143f0a730bc21d3ecfb3d [Bluetooth] Add compat handling for timestamp structure

:::::: TO: Marcel Holtmann <marcel@holtmann.org>
:::::: CC: Marcel Holtmann <marcel@holtmann.org>

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
