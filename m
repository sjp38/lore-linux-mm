Date: Thu, 17 Aug 2000 01:50:13 +0200
From: Jakob Oestergaard <joe@solit.dk>
Subject: Oops - riel vm
Message-ID: <20000817015013.A17459@solit.dk>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="r5Pyd7+fXNt84Ff3"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--r5Pyd7+fXNt84Ff3
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline


As requested by Rick on IRC, I'm forwarding an oops
I got on a UP box with 2.4-test7-pre3.

Sorry, no System.map, but I'll test this myself tomorrow
and supply proper documentation if I can make it break
as well.

Oops attached.

The box runs stable without the rick-vm patch, and it
does get beaten half-way to death daily, so I have a good
reason to believe that either Rick's patch is the fault, or it
triggers some other bug.

Cheers,
-- 
-------------------+----------------------------------
 Jakob Oestergaard | Software design & implementation
  joe@solit.dk     | { It compiles, therefore it is }
-------------------+---+------------------------------
 Solit Solutions ApS.  |  http://www.sysorb.com/
-----------------------+------------------------------

--r5Pyd7+fXNt84Ff3
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="oops.text"

Jun 10 18:36:30 hawk kernel: memory : c750d3e0 
Jun 10 19:22:03 hawk kernel: Unable to handle kernel paging request at virtual address 5a5a5a6e 
Jun 10 19:22:03 hawk kernel:  printing eip: 
Jun 10 19:22:03 hawk kernel: c0163ef9 
Jun 10 19:22:03 hawk kernel: *pde = 00000000 
Jun 10 19:22:03 hawk kernel: Oops: 0000 
Jun 10 19:22:03 hawk kernel: CPU:    0 
Jun 10 19:22:03 hawk kernel: EIP:    0010:[ipcperms+45/164] 
Jun 10 19:22:03 hawk kernel: EFLAGS: 00013202 
Jun 10 19:22:03 hawk kernel: eax: 000001b6   ebx: 000001b6   ecx: 00000036   edx: 000001b6 
Jun 10 19:22:03 hawk kernel: esi: c7626000   edi: 00000000   ebp: 5a5a5a5a   esp: c7627f3c 
Jun 10 19:22:03 hawk kernel: ds: 0018   es: 0018   ss: 0018 
Jun 10 19:22:03 hawk kernel: Process X (pid: 621, stackpage=c7627000) 
Jun 10 19:22:03 hawk kernel: Stack: 000001b6 00000001 00000000 00000002 000001b6 00000000 c01694a6 5a5a5a5a  
Jun 10 19:22:04 hawk kernel:        000001b6 00000000 00000000 00000001 bffffb7c 00000003 00000001 00000000  
Jun 10 19:22:04 hawk kernel:        00000fec 00000000 00000000 c7627f78 c010f8cd 00000001 00000000 00000000  
Jun 10 19:22:04 hawk kernel: Call Trace: [sys_shmat+210/876] [sys_ipc+337/500] [error_code+45/52] [system_call+52/56] [startup_32+43/309]  
Jun 10 19:22:04 hawk kernel: Code: 0f b7 5d 14 89 74 24 14 8b 86 20 01 00 00 3b 45 0c 74 05 3b  

--r5Pyd7+fXNt84Ff3--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
