Date: Thu, 17 Aug 2000 02:08:57 +0200
From: Jakob Oestergaard <joe@solit.dk>
Subject: Re: Oops - riel vm
Message-ID: <20000817020857.A17604@solit.dk>
References: <20000817015013.A17459@solit.dk>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="ZGiS0Q5IWpPtfppv"
Content-Disposition: inline
In-Reply-To: <20000817015013.A17459@solit.dk>; from joe@solit.dk on Thu, Aug 17, 2000 at 01:50:13AM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--ZGiS0Q5IWpPtfppv
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Duh !

I sent the wrong oops just before  :*(

The dates fit very bad with test7-pre3...  This is
the right oops.

It seems strangely related to the other one though,
way before we tried riel-vm...

This mail hopefully clears up any mess I left with
the last post, and now I'll promise to shut up until
tomorrow when I can get some better testing done.

Sorry for the confusion, 
-- 
-------------------+----------------------------------
 Jakob Oestergaard | Software design & implementation
  joe@solit.dk     | { It compiles, therefore it is }
-------------------+---+------------------------------
 Solit Solutions ApS.  |  http://www.sysorb.com/
-----------------------+------------------------------

--ZGiS0Q5IWpPtfppv
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="oops.text"

Aug 16 13:59:27 hawk kernel: memory : c7ca2ce0 
Aug 16 14:28:07 hawk kernel: Unable to handle kernel paging request at virtual address f72b5eb8 
Aug 16 14:28:07 hawk kernel:  printing eip: 
Aug 16 14:28:07 hawk kernel: c016252d 
Aug 16 14:28:07 hawk kernel: *pde = 00000000 
Aug 16 14:28:07 hawk kernel: Oops: 0000 
Aug 16 14:28:07 hawk kernel: CPU:    0 
Aug 16 14:28:08 hawk kernel: EIP:    0010:[ipcperms+45/176] 
Aug 16 14:28:08 hawk kernel: EFLAGS: 00013202 
Aug 16 14:28:08 hawk kernel: eax: 000001b6   ebx: 00000001   ecx: 00000036   edx: 000001b6 
Aug 16 14:28:08 hawk kernel: esi: c643e000   edi: 00000000   ebp: f72b5ea4   esp: c643ff3c 
Aug 16 14:28:08 hawk kernel: ds: 0018   es: 0018   ss: 0018 
Aug 16 14:28:08 hawk kernel: Process XFree86 (pid: 979, stackpage=c643f000) 
Aug 16 14:28:08 hawk kernel: Stack: 00000001 000001b6 00000000 00000002 000001b6 00000000 c0166e9c f72b5ea4  
Aug 16 14:28:08 hawk kernel:        000001b6 00000000 00000000 00000001 bffff894 00000000 00000003 00000001  
Aug 16 14:28:08 hawk kernel:        00000fec 00000000 00000000 c643ff78 c010d5dd 00000001 00000000 00000000  
Aug 16 14:28:08 hawk kernel: Call Trace: [sys_shmat+216/620] [<f72b5ea4>] [sys_ipc+337/500] [system_call+51/56]  
Aug 16 14:28:08 hawk kernel: Code: 0f b7 5d 14 89 74 24 14 8b 86 14 01 00 00 3b 45 0c 74 05 3b  

--ZGiS0Q5IWpPtfppv--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
