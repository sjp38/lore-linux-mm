Subject: Re: [PATCH *] rmap VM, version 12
Message-ID: <OFB07135FF.E6C5BE7E-ON88256B4A.0068CB3F@boulder.ibm.com>
From: "Badari Pulavarty" <badari@us.ibm.com>
Date: Wed, 23 Jan 2002 11:02:37 -0800
MIME-Version: 1.0
Content-type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: riel@conectiva.com.br
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Does this explain why my SMP box does not boot with rmap12 ? It works fine
with rmap11c.

Machine: 4x  500MHz Pentium Pro with 3GB RAM

When I tried to boot 2.4.17+rmap12, last message I see is

uncompressing linux ...
booting ..


Thanks,
Badari



                                                                                                         
                    "David S.                                                                            
                    Miller"              To:     riel@conectiva.com.br                                   
                    <davem@redhat.       cc:     linux-mm@kvack.org, linux-kernel@vger.kernel.org        
                    com>                 Subject:     Re: [PATCH *] rmap VM, version 12                  
                    Sent by:                                                                             
                    owner-linux-mm                                                                       
                    @kvack.org                                                                           
                                                                                                         
                                                                                                         
                    01/23/02 10:44                                                                       
                    AM                                                                                   
                                                                                                         
                                                                                                         



     - use fast pte quicklists on non-pae machines           (Andrea
Arcangeli)

Does this work on SMP?  I remember they were turned off because
they were simply broken on SMP.

The problem is that when vmalloc() or whatever kernel mappings change
you have to update all the quicklist page tables to match.

Andrea probably fixed this, I haven't looked at the patch.
If so, ignoreme.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
