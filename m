From: aprasad@in.ibm.com
Message-ID: <CA256996.004352F8.00@d73mta05.au.ibm.com>
Date: Mon, 13 Nov 2000 17:29:48 +0530
Subject: reliability of linux-vm subsystem
Mime-Version: 1.0
Content-type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

When i run following code many times.
System becomes useless till all of the instance of this programming are
killed by vmm.
Till that time linux doesn't accept any command though it switches from one
VT to another but its useless.
The above programme is run as normal user previleges.
Theoretically load should increase but system should services other users
too.
but this is not behaving in that way.
___________________________________________________________________
main()
{
     char *x[1000];
     int count=1000,i=0;
     for(i=0; i <count; i++)
          x[i] = (char*)malloc(1024*1024*10); /*10MB each time*/

}
_______________________________________________________________________
If i run above programm for 10 times , then system is useless for around
5-7minutes on PIII/128MB.

regards,
Anil


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
